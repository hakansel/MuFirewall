#!/usr/local/bin/php -f
<?php
//!HHATODO: log or alert email, sms etc if there is not access.log file
$squid_log_file = '/var/squid/logs/access.log';
$line = exec("wc -l {$squid_log_file} | awk '{print $1}'");
$bool_first = true;
while (true) {

    $curr_line = exec("wc -l {$squid_log_file} | awk '{print $1}'");
    if(($line <= $curr_line) && !($bool_first)) {
        $logarr = mu_squid_fetch_log($squid_log_file);
        
        foreach ($logarr as $value) {
            $logline = preg_split("/\s+/", $value);
        }

        if($logline[1] != $sid) {
            $sid = $logline[1];
            $user = mu_get_cp_user_by_ip($logline[2]);
            shell_exec("logger -s cpacc -t {$user[0][0]} - {$logline[2]} {$logline[6]} {$logline[8]}");
        }
        $line++;
        $bool_first = false;
    } else {
        sleep(60);
    }
}
// $pos = exec("wc -l ${squid_log_file}");
// tail($squid_log_file, $pos);
// echo tailCustom($squid_log_file, 1, "true");

// Return Squid Logs as line as array.
function mu_squid_fetch_log($squid_log_file){   

    $lines = 1;
    
    exec("tail -n {$lines} {$squid_log_file}", $logline);
    // return logs
    return $logline;
}

//!HHATODO: log or alert email, sms etc if there is not captiveportalmu_zone.db or different name.
function mu_captiveportal_opendb() {
        global $g, $cpzone;

        if (file_exists("/var/db/captiveportalcfm_zone.db"))
                $DB = @sqlite_open("/var/db/captiveportalcfm_zone.db");
        else {
                $errormsg = "There are no database with captiveportalcfm_zone.db";
                captiveportal_syslog("Error during table mu_zone creation. Error message: {$errormsg}");
        }

        return $DB;
}

function tailCustom($filepath, $lines = 1, $adaptive = true) {

        // Open file
        $f = @fopen($filepath, "rb");
        if ($f === false) return false;

        // Sets buffer size
        if (!$adaptive) $buffer = 4096;
        else $buffer = ($lines < 2 ? 64 : ($lines < 10 ? 512 : 4096));

        // Jump to last character
        fseek($f, -1, SEEK_END);

        // Read it and adjust line number if necessary
        // (Otherwise the result would be wrong if file doesn't end with a blank line)
        if (fread($f, 1) != "\n") $lines -= 1;
        
        // Start reading
        $output = '';
        $chunk = '';

        // While we would like more
        while (ftell($f) > 0 && $lines >= 0) {

            // Figure out how far back we should jump
            $seek = min(ftell($f), $buffer);

            // Do the jump (backwards, relative to where we are)
            fseek($f, -$seek, SEEK_CUR);

            // Read a chunk and prepend it to our output
            $output = ($chunk = fread($f, $seek)) . $output;

            // Jump back to where we started reading
            fseek($f, -mb_strlen($chunk, '8bit'), SEEK_CUR);

            // Decrease our line counter
            $lines -= substr_count($chunk, "\n");

        }

        // While we have too many lines
        // (Because of buffer size we might have read too many)
        while ($lines++ < 0) {

            // Find first newline and remove all text before that
            $output = substr($output, strpos($output, "\n") + 1);

        }

        // Close file and return
        fclose($f);
        return trim($output);

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

function tail($file,&$pos) {
    // get the size of the file
    if(!$pos) $pos = filesize($file);
    // Open an inotify instance
    $fd = inotify_init();
    // Watch $file for changes.
    $watch_descriptor = inotify_add_watch($fd, $file, IN_ALL_EVENTS);
    // Loop forever (breaks are below)
    while (true) {
        // Read events (inotify_read is blocking!)
        $events = inotify_read($fd);
        // Loop though the events which occured
        foreach ($events as $event=>$evdetails) {
            // React on the event type
            switch (true) {
                // File was modified
                case ($evdetails['mask'] & IN_MODIFY):
                    // Stop watching $file for changes
                    inotify_rm_watch($fd, $watch_descriptor);
                    // Close the inotify instance
                    fclose($fd);
                    // open the file
                    $fp = fopen($file,'r');
                    if (!$fp) return false;
                    // seek to the last EOF position
                    fseek($fp,$pos);
                    // read until EOF
                    while (!feof($fp)) {
                        $buf .= fread($fp,8192);
                        echo $buf;
                    }
                    // save the new EOF to $pos
                    $pos = ftell($fp); // (remember: $pos is called by reference)
                    // close the file pointer
                    fclose($fp);
                    // return the new data and leave the function
                    return $buf;
                    // be a nice guy and program good code ;-)
                    break;

                    // File was moved or deleted
                case ($evdetails['mask'] & IN_MOVE):
                case ($evdetails['mask'] & IN_MOVE_SELF):
                case ($evdetails['mask'] & IN_DELETE):
                case ($evdetails['mask'] & IN_DELETE_SELF):
                    // Stop watching $file for changes
                    inotify_rm_watch($fd, $watch_descriptor);
                    // Close the inotify instance
                    fclose($fd);
                    // Return a failure
                    return false;
                    break;
            }
        }
    }
}

?>