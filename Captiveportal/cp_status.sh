#!/usr/local/bin/php -f
<?php

#require_once("/etc/inc/captiveportal.inc");

$cpdb = mu_captiveportal_read_db();

foreach($cpdb as $res){
        foreach($res as $elem) {
                $user .= "\t$elem";
        }
        `/usr/bin/logger -t cpauth -s $user`;
        $user = "";
}

function mu_captiveportal_opendb() {
        global $g, $cpzone;

        if (file_exists("/var/db/captiveportalmu_zone.db"))
                $DB = @sqlite_open("/var/db/captiveportalmu_zone.db");
        else {
                $errormsg = "";
                $DB = @sqlite_open("/var/db/captiveportalmu_zone.db");
                if (@sqlite_exec($DB, "CREATE TABLE captiveportal (allow_time INTEGER, pipeno INTEGER, ip TEXT, mac TEXT, us
ername TEXT, sessionid TEXT, bpassword TEXT, session_timeout INTEGER, idle_timeout INTEGER, session_terminate_time INTEGER,
interim_interval INTEGER, radiusctx TEXT) ", $errormsg)) {
                        @sqlite_exec($DB, "CREATE UNIQUE INDEX idx_active ON captiveportal (sessionid, username)");
                        @sqlite_exec($DB, "CREATE INDEX user ON captiveportal (username)");
                        @sqlite_exec($DB, "CREATE INDEX ip ON captiveportal (ip)");
                        @sqlite_exec($DB, "CREATE INDEX starttime ON captiveportal (allow_time)");
                        @sqlite_exec($DB, "CREATE INDEX serviceid ON captiveportal (serviceid)");
                } else
                        captiveportal_syslog("Error during table mu_zone creation. Error message: {$errormsg}");
        }

        return $DB;
}

/* read captive portal DB into array */
function mu_captiveportal_read_db($query = "") {

        $DB = mu_captiveportal_opendb();
        if ($DB) {
                sqlite_exec($DB, "BEGIN");
                if (!empty($query))
                        $cpdb = @sqlite_array_query($DB, "SELECT * FROM captiveportal {$query}", SQLITE_NUM);
                else {
                        $response = @sqlite_unbuffered_query($DB, "SELECT * FROM captiveportal", SQLITE_NUM);
                        $cpdb = @sqlite_fetch_all($response, SQLITE_NUM);
                }
                sqlite_exec($DB, "END");
                @sqlite_close($DB);
        }
        if (!$cpdb)
                $cpdb = array();

        return $cpdb;
}

?>