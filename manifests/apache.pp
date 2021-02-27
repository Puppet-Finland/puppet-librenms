#
# @summary setup apache2 reverse proxy for LibreNMS
#
# @param servername
#   Virtualhost servername
# @param ssl
#   Use SSL. Only supports default snakeoil certificates right now.
#
class librenms::apache
(
  Optional[String] $servername,
  Boolean          $ssl
)
{
  class { '::apache':
    purge_configs => true,
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  include ::apache::mod::php
  include ::apache::mod::headers
  include ::apache::mod::rewrite

  $https_virtualhost_ensure = $ssl ? {
    true    => 'present',
    default => 'absent',
  }

  apache::vhost {
    default:
      servername            => $servername,
      docroot               => '/opt/librenms/html',
      docroot_owner         => 'librenms',
      docroot_group         => 'librenms',
      allow_encoded_slashes => 'nodecode',
      proxy_pass            =>
      [
        {
          'path' => '/opt/librenms/html/',
          'url'  => '!',
        }
      ],
      directories           =>
        [
          {
            'path'           => '/opt/librenms/html/',
            'require'        => 'all granted',
            'options'        => ['FollowSymLinks', 'MultiViews'],
            'allow_override' => 'All',
          }
        ],
    ;
    ['librenms-https']:
      ensure          => $https_virtualhost_ensure,
      port            => 443,
      ssl             => true,
      ssl_cert        => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
      ssl_key         => '/etc/ssl/private/ssl-cert-snakeoil.key',
      request_headers => [ 'set X-Forwarded-Proto "https"', 'set X-Forwarded-Port "443"' ],
      headers         => [ 'always set Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"' ]
    ;
    ['librenms-http']:
      ensure          => 'present',
      port            => 80,
      request_headers => [ 'set X-Forwarded-Proto "http"', 'set X-Forwarded-Port "80"' ]
    ;
  }
}
