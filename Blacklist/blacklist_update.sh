#!/usr/local/bin/php -f
<?php
define("SGBAR_SIZE",     "450");
    $incl = "/usr/local/pkg/squidguard_configurator.inc";
    if (file_exists($incl)) {
        require_once($incl);
        sg_reconfigure_blacklist( "ftp://10.10.10.10:21/shallalist.tar.gz", "" );
	# Activity
    	# Rebuild progress /check SG rebuild process/
    	if (is_squidGuardProcess_rebuild_started()) {
        	$pcaption = 'Blacklist DB rebuild progress';
        	$sz = squidguar_blacklist_rebuild_progress();
    	}
    	elseif (squidguard_blacklist_update_IsStarted()) {
        	$pcaption = 'Blacklist download progress';
        	$sz = squidguard_blacklist_update_progress();
    	}

    	# progress status
    	$szleft  = $sz * SGBAR_SIZE / 100;
	echo $szleft;
    	$szright = SGBAR_SIZE - $szleft;
	echo $szright;
    }
function is_squidGuardProcess_rebuild_started()
{
    # memo: 'ps -auxw' used 132 columns; 'ps -auxww' used 264 columns
    # if cmd more then 132 need use 'ww..' key
    return exec("ps -auxwwww | grep 'squidGuard -c .* -C all' | grep -v grep | awk '{print $2}' | wc -l | awk '{ print $1 }'");
}

    exit;
?>
