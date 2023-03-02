# @summary Updates the list of available packages using apt-get update.
#
# @api private
#
class apt::update {
  assert_private()

  #TODO: to catch if $apt_update_last_success has the value of -1 here. If we
  #opt to do this, a info/warn would likely be all you'd need likely to happen
  #on the first run, but if it's not run in awhile something is likely borked
  #with apt and we'd want to know about it.

  case $apt::_update['frequency'] {
    'always': {
      $_kick_apt = true
    }
    'daily': {
      #compare current date with the apt_update_last_success fact to determine
      #if we should kick apt_update.
      $daily_threshold = (Integer(Timestamp().strftime('%s')) - 86400)
      if $apt::apt_update_last_success {
        if $apt::apt_update_last_success + 0 < $daily_threshold {
          $_kick_apt = true
        } else {
          $_kick_apt = false
        }
      } else {
        #if apt-get update has not successfully run, we should kick apt_update
        $_kick_apt = true
      }
    }
    'weekly':{
      #compare current date with the apt_update_last_success fact to determine
      #if we should kick apt_update.
      $weekly_threshold = (Integer(Timestamp().strftime('%s')) - 604800)
      if $apt::apt_update_last_success {
        if ( $apt::apt_update_last_success + 0 < $weekly_threshold ) {
          $_kick_apt = true
        } else {
          $_kick_apt = false
        }
      } else {
        #if apt-get update has not successfully run, we should kick apt_update
        $_kick_apt = true
      }
    }
    default: {
      #catches 'reluctantly', and any other value (which should not occur).
      #do nothing.
      $_kick_apt = false
    }
  }

  if $_kick_apt {
    $_refresh = false
  } else {
    $_refresh = true
  }
  # We perform the update in an `unless` clause of the exec, and
  # return true only if the `/var/cache/apt/pkgcache.bin` file changed.
  # This ensures that Puppet does not report a change if the
  # update command had no effect. See MODULES-10763 for discussion.
  exec { 'apt_update':
    command     => "echo ${apt::provider} updated the package cache.",
    loglevel    => $apt::_update['loglevel'],
    logoutput   => 'on_failure',
    path        => '/bin:/usr/bin',
    provider    => shell,
    refreshonly => $_refresh,
    timeout     => $apt::_update['timeout'],
    tries       => $apt::_update['tries'],
    unless      => epp('apt/update_had_no_effect.sh.epp'),
  }
}
