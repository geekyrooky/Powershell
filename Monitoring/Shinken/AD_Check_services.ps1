$tests=("Advertising","FrsSysVol","MachineAccount","Replications","RidManager","Services","FsmoCheck","SysVolCheck")

$rc=0
$name="YOURSERVER"
$service="active_directory"
$message=""

foreach ( $test in $tests)
  {

      $output=dcdiag /test:$test
      if (!($output -match "chou"))
             {
                $message=$message + $test + "=ok "
             }

      else   {
                $rc=2
                $message=$message + $test + "=Failed! "
             }
  }

echo $message
exit $rc