#!/usr/local/bin/php -f
<?php
//!HHATODO: access.log yoksa bunu bir loga basmasi ya da bir ikaz mekanizmasi gelistirilmeli.
$squid_log_file = '/var/squid/logs/access.log';

while (true) {
//     # code...
    $logarr = mu_squid_fetch_log($squid_log_file);
    
    foreach ($logarr as $value) {
        # code...
        $logline = preg_split("/\s+/", $value);
    }

    if($logline[1] != $sid) {
        $sid = $logline[1];
        $user = mu_get_cp_user_by_ip($logline[2]);
        shell_exec("logger -s access -t {$user[0][0]} {$logline[2]} {$logline[6]} {$logline[8]}");
    }       
}

// Return Squid Logs as line as array.
function mu_squid_fetch_log($squid_log_file){   

    $lines = 1;
    
    exec("tail -n {$lines} {$squid_log_file}", $logline);
    // return logs
    return $logline;
};

//!HHATODO: mu_zone isminde bir captiveportal yoksa eger bunu bir loga basmasi ya da bir ikaz mekanizmasi gelistirilmeli.
function mu_captiveportal_opendb() {
        global $g, $cpzone;

        if (file_exists("/var/db/captiveportalmu_zone.db"))
                $DB = @sqlite_open("/var/db/captiveportalmu_zone.db");
        else {
                $errormsg = "There are no database with captiveportalmu_zone.db";
                captiveportal_syslog("Error during table mu_zone creation. Error message: {$errormsg}");
        }

        return $DB;
}

/* read captive portal DB where queried ip into array */
function mu_get_cp_user_by_ip($ip = "") {

        $cp_main_query = 'SELECT username FROM captiveportal WHERE ip=';

        if(!empty($ip))
        {
            $query = $cp_main_query . "'" . $ip . "'";
        }
        else 
        {
            captiveportal_syslog("Error during read ip from mu_zone database. Empty ip!");
            return "";
        }

        $DB = mu_captiveportal_opendb();
        if ($DB) {
                sqlite_exec($DB, "BEGIN");
                $cpdb = @sqlite_array_query($DB, "{$query}", SQLITE_NUM);
                sqlite_exec($DB, "END");
                @sqlite_close($DB);
        }

        return $cpdb;
}

?>