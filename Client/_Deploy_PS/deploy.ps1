# vek 03/08/2018
# �������������� ������������� MailToOwnCloud
#
# ������������ python-simple-http-logger
# https://github.com/kovalewvladimir/python-simple-http-logger
#
# Invoke-WebRequest                                          `
# -Uri "http://<server>:9000/MailToOwnCloud/<name_log>.log" `
# -Method Post -Body @{"t"= $logString}                  `
# | Out-Null

# �����������
$logDir  = $env:APPDATA + "\log_scripts_gpo\"
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType directory
}
$logFile = $logDir + "deployMailToOwnCloud.log"
Get-Date >> $logFile
$logString = ""

# ���� �� csv ����� � ��������
$pathCsvFile = $PSScriptRoot + "\access.csv"
# ��� ������ ���������
$nameLink = "������ ��� ��������.lnk"
# ���� �� ������ ���������
$pathLink = "\\<������>\NETLOGON\MailToOwnCloud\" + $nameLink
# ���� �� ����� SendTo
$pathSendTo = $env:APPDATA + "\Microsoft\Windows\SendTo\"
# ���� �� ������ � SendTo
$pathLinkSendTo = $pathSendTo + $nameLink
# ������� ����
$currentDate = Get-Date
# ������ �������
$access = Import-Csv -Path $pathCsvFile

$(
    foreach($a in $access) {
        if ($a.USER.ToUpper() -ne $env:USERNAME) {
            continue
        }
        $date = Get-Date -Date $a.Date
        if ($currentDate -lt $date) {
            # ����������� ������
            if (Test-Path -Path $pathLinkSendTo) {
                $logString += "INFO: ����� ��� ���������� � ������������ $($env:USERNAME) �� ���������� $($env:COMPUTERNAME). ����� ������ $($date)"
            } else {
                $logString += "INFO: ����������� ������ ������������ $($env:USERNAME) �� ���������� $($env:COMPUTERNAME)"
                Copy-Item -Path $pathLink -Destination $pathSendTo
                Invoke-WebRequest                                          `
                    -Uri "http://<server>:9000/MailToOwnCloud/_COPY.log" `
                    -Method Post -Body @{"t"= $logString}                  `
                | Out-Null
            }
        } else {
            # �������� ������
            if (Test-Path -Path $pathLinkSendTo) {
                $logString += "INFO: �������� ������ � ������������ $($env:USERNAME) �� ���������� $($env:COMPUTERNAME)"
                Remove-Item -Path $pathLinkSendTo
                Invoke-WebRequest                                            `
                    -Uri "http://<server>:9000/MailToOwnCloud/_DELETE.log" `
                    -Method Post -Body @{"t"= $logString}                    `
                | Out-Null
            } else {
                $logString += "INFO: ����� ��� ������ � ������������ $($env:USERNAME) �� ���������� $($env:COMPUTERNAME). ������ $($date)"
            }
        }
        # ����� ����
        $logString

        # �������� ���� �� ������
        Invoke-WebRequest                                                         `
            -Uri "http://<server>:9000/MailToOwnCloud/$($env:COMPUTERNAME).log" `
            -Method Post -Body @{"t"= $logString}                                 `
        | Out-Null
    }
) *>&1>> $logFile