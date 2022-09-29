# FeeLCoMz Simple Daily FUP v1.1
# © Nov 2020, By Rony Nofrianto
#
# Description:
# Script untuk menurunkan total bandwidth pada simple queue ketika klien mencapai kuota FUP yang ditentukan. Lebih cocok digunakan untuk static simple queue.
#
# Usage:
# + Copy paste script ini ke system script anda.
# + Edit parameter sesuai kebutuhan.
# + Atur scheduler untuk menjalankan script dengan interval yang anda inginkan. Contoh: per 10 menit, per 1 jam, dll.
#
# Version History
# v1.1
# + Perubahan parameter Simple Queue Number ke Simple Queue Name.
# + Penambahan fitur reset counter.

##############
# Parameters #
##############

# <sSQueueName> - Nama simple queue yang ingin anda limit.
:local sSQueueName "INTERNET";

# <iFUPGB> - Kuota Fair Usage Policy dalam satuan GigaByte. Bila penggunaan kuota mencapai batas ini, kecepatan akan diturunkan sesuai nilai bandwidth FUP.
:local iFUPGB 60;

# <iFUPBW> - Bandwidth FUP dalam satuan Mbps.
:local iFUPBW 20;

# <iNormalBW> - Bandwidth Normal dalam satuan Mbps.
:local iNormalBW 100;

# <bResetCounter> - Aktifkan reset counter (true/false).
:local bResetCounter false;

#################
# Routine Start #
#################
/queue simple;

:local iSQueueItemNumber [find where name=$sSQueueName];
:local curTotalBytes  [get $iSQueueItemNumber total-bytes];
:local bReachFUP  ( ($curTotalBytes/(1000*1000*1000))>=$iFUPGB );
:local bFUPBW  ( [get $iSQueueItemNumber total-max-limit]=($iFUPBW*1000000) );
:local bNormalBW  ( [get $iSQueueItemNumber total-max-limit]=($iNormalBW*1000000) );

:if ($bReachFUP && !$bFUPBW) do={
   set $iSQueueItemNumber total-max-limit=($iFUPBW*1000000);
   :if ($bResetCounter) do={ reset-counters $iSQueueItemNumber; };
};

:if (!$bReachFUP && !$bNormalBW ) do={
   set $iSQueueItemNumber total-max-limit=($iNormalBW*1000000);
};
