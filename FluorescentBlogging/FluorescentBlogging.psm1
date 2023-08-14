
# 4 - ��������� ������� �� ����������
    # 8 - ��� ������ � �������� ��������
    # 12 - �������� �� ���������� �������� �� FTP ���������
    # 16 - ���� � �������� �������� �� ������������� ������� ��������
    # 20 - ����� ��� ������ �����������
    # 24 - ������ �� ��������
    # 28 - FTP-������� ��� ������ 
    # 32 - ���� �� FTP, �� ������������� ������� ���������
    # 36 - �������� ����� �� �������� FTP-������� � ��������� ������� ���������
    # 40 - ���� �� �������� FTP-������� � ��������� ������� �� ����� ���� ������
    # 44 - ���� �� �������� FTP-������� ������ ����� ���������
    # 48 - ��������� "FM" �� ����������� ��� ����������� �����������
    # 52 - ��� �������� ��� ����� �� FTP

Function Blogging { 

Param ( 
    [Parameter(Mandatory=$true)] $event,
    [Parameter(Mandatory=$false)] $argument,
    [Parameter(Mandatory=$false)] $place
)

Foreach ( $e in $event){  

 if ($e -eq $null) { continue } else { $w = $e.Split("|") }

    Switch ($w[0]){
         "4" { Write-Host ( "{0} {1} - {2} {3} {4}" -f "`t`t", (Date), "��������� �������", $argument.localPath, "�� ����������" ) }
         #"8" { Write-Host ( "{0} {1} - {2} {3}" -f "`t`t", (Date), "��� ����� ��� �������� � ��������", $argument.localPath ) }
        #"12" { Write-Host ( "{0} {1}   {2}{3} {4} {5}{6}" -f "`t`t", (Date), $argument.localPath, $w[1], ">>>", $argument.FtpDirectory, $w[1] ) }
        "12" { 

               if ( $argument.Description -eq "FMi" ) {
                    $y = "��������� �� FM"
                    Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), $y ) -ForegroundColor Magenta
               }
               
               if ( $argument.Description -eq "TKi" ) {
                    $y = "��������� �� ����"
                    Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), $y ) -ForegroundColor Cyan 
               }
              

             }

        #"16" { Write-Host ( "{0} {1} - {2}{3} {4}" -f "`t`t", (Date), $argument.localPath, $w[1],"- ���� � �������� �������� �� ������������� ������� ��������" ) }
        #"16" { Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), ">>>" ) }
        "20" { Write-Host ( "{0} {1} - {2}" -f "`t`t", (Date), "����� ��� ������ �����������" ) }
        "24" { Write-Host ( "{0} {1} - {2}" -f "`t`t", (Date), "������ �� ��������" ) }
        #"28" { Write-Host ( "{0} {1} {2} {3}{4}{5} {6} {7} {8} {9}" -f "`t`t", (Date), "��� ����� ����", '"',  $argument.Description, '"', "��", $argument.FtpDirectory, "�", $argument.localPath ) }
        #"28" { Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), ">>>" ) }
        #"32" { Write-Host ( "{0} {1} - {2} {3}{4} {5}" -f "`t`t", (Date), "���� �� �������", $argument.FtpDirectory, $w[1], "�� ������������� ������� ������") }
        #"32" { Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), ">>>" ) }
        #"36" { Write-Host  ( "{0} {1} - {2}{3} {4} {5}{6}" -f "`t`t", (Date), $argument.FtpDirectory, $w[1], ">>>", $argument.localPath, $w[1] ) }
        "36" { 
                if ( $argument.Description -eq "IG" ) { $s = "������ ��� FM";  Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s ) -ForegroundColor Yellow }
                if ( $argument.Description -eq "UG" ) { 
                    $s = "������ ��� FM"; Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s )  -ForegroundColor Yellow -NoNewline
                    Write-Host  ( "{0} {1}" -f " ", "����������" )  -ForegroundColor DarkYellow
                }
                if ( $argument.Description -eq "IT" ) { $s = "������ ��� ��T�";  Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s ) -ForegroundColor Yellow  }
                if ( $argument.Description -eq "UT" ) { 
                    $s = "������ ��� ����"; Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s )  -ForegroundColor Yellow -NoNewline
                    Write-Host  ( "{0} {1}" -f " ", "����������" )  -ForegroundColor DarkYellow
                }
               
             }
        
        #"40" { Write-Host ( "{0} {1} - {2} {3}{4} {5}" -f "`t`t", (Date), "���� � �������", $argument.FtpDirectory, $w[1], "�� ����� ���� ������") }
        #"44" { Write-Host ( "{0} {1} - {2} {3}{4} {5}" -f "`t`t", (Date), "���� � �������", $argument.FtpDirectory, $w[1], "������ ����� ���������") }
        "48" { Write-Host ( "{0} {1} - {2}" -f "`t`t", (Date), "��������� 'FM' �� ����������� ��� ����������� �����������") }
        "52" { Write-Host ( "{0} {1} - {2} {3} {4}" -f "`t`t", (Date), "�� ���������� ����", $argument.FtpDirectory , "�� �������") }
    }
}
    
} # ********************************************************************************** </Function Blogging >