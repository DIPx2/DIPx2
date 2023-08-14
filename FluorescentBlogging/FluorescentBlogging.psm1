
# 4 - Локальный каталог не существует
    # 8 - Нет файлов в каталоге отправки
    # 12 - Отправка из локального каталога на FTP произошла
    # 16 - Файл в каталоге отправки не соответствует шаблону отправки
    # 20 - Логин или пароль некорректны
    # 24 - Сервер не отвечает
    # 28 - FTP-каталог без файлов 
    # 32 - Файл на FTP, не соответствует шаблону получения
    # 36 - Загрузка файла из каталога FTP-сервера в локальный каталог произошла
    # 40 - Файл из каталога FTP-сервера в локальный каталог не может быть принят
    # 44 - Файл из каталога FTP-сервера удален после получения
    # 48 - Программа "FM" не установлена или установлена некорректно
    # 52 - Нет каталога или файла на FTP

Function Blogging { 

Param ( 
    [Parameter(Mandatory=$true)] $event,
    [Parameter(Mandatory=$false)] $argument,
    [Parameter(Mandatory=$false)] $place
)

Foreach ( $e in $event){  

 if ($e -eq $null) { continue } else { $w = $e.Split("|") }

    Switch ($w[0]){
         "4" { Write-Host ( "{0} {1} - {2} {3} {4}" -f "`t`t", (Date), "Локальный каталог", $argument.localPath, "не существует" ) }
         #"8" { Write-Host ( "{0} {1} - {2} {3}" -f "`t`t", (Date), "Нет файла для отправки в каталоге", $argument.localPath ) }
        #"12" { Write-Host ( "{0} {1}   {2}{3} {4} {5}{6}" -f "`t`t", (Date), $argument.localPath, $w[1], ">>>", $argument.FtpDirectory, $w[1] ) }
        "12" { 

               if ( $argument.Description -eq "FMi" ) {
                    $y = "отправлен из FM"
                    Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), $y ) -ForegroundColor Magenta
               }
               
               if ( $argument.Description -eq "TKi" ) {
                    $y = "отправлен из КлТК"
                    Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), $y ) -ForegroundColor Cyan 
               }
              

             }

        #"16" { Write-Host ( "{0} {1} - {2}{3} {4}" -f "`t`t", (Date), $argument.localPath, $w[1],"- Файл в каталоге отправки не соответствует шаблону отправки" ) }
        #"16" { Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), ">>>" ) }
        "20" { Write-Host ( "{0} {1} - {2}" -f "`t`t", (Date), "Логин или пароль некорректны" ) }
        "24" { Write-Host ( "{0} {1} - {2}" -f "`t`t", (Date), "Сервер не отвечает" ) }
        #"28" { Write-Host ( "{0} {1} {2} {3}{4}{5} {6} {7} {8} {9}" -f "`t`t", (Date), "Нет файла типа", '"',  $argument.Description, '"', "из", $argument.FtpDirectory, "в", $argument.localPath ) }
        #"28" { Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), ">>>" ) }
        #"32" { Write-Host ( "{0} {1} - {2} {3}{4} {5}" -f "`t`t", (Date), "Файл на сервере", $argument.FtpDirectory, $w[1], "не соответствует шаблону приема") }
        #"32" { Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), ">>>" ) }
        #"36" { Write-Host  ( "{0} {1} - {2}{3} {4} {5}{6}" -f "`t`t", (Date), $argument.FtpDirectory, $w[1], ">>>", $argument.localPath, $w[1] ) }
        "36" { 
                if ( $argument.Description -eq "IG" ) { $s = "принят для FM";  Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s ) -ForegroundColor Yellow }
                if ( $argument.Description -eq "UG" ) { 
                    $s = "принят для FM"; Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s )  -ForegroundColor Yellow -NoNewline
                    Write-Host  ( "{0} {1}" -f " ", "обновление" )  -ForegroundColor DarkYellow
                }
                if ( $argument.Description -eq "IT" ) { $s = "принят для КлTК";  Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s ) -ForegroundColor Yellow  }
                if ( $argument.Description -eq "UT" ) { 
                    $s = "принят для КлТК"; Write-Host  ( "{0} {1} {2}" -f "`t`t", (Date), $s )  -ForegroundColor Yellow -NoNewline
                    Write-Host  ( "{0} {1}" -f " ", "обновление" )  -ForegroundColor DarkYellow
                }
               
             }
        
        #"40" { Write-Host ( "{0} {1} - {2} {3}{4} {5}" -f "`t`t", (Date), "Файл с сервера", $argument.FtpDirectory, $w[1], "не может быть приянт") }
        #"44" { Write-Host ( "{0} {1} - {2} {3}{4} {5}" -f "`t`t", (Date), "Файл с сервера", $argument.FtpDirectory, $w[1], "удален после получения") }
        "48" { Write-Host ( "{0} {1} - {2}" -f "`t`t", (Date), "Программа 'FM' не установлена или установлена некорректно") }
        "52" { Write-Host ( "{0} {1} - {2} {3} {4}" -f "`t`t", (Date), "Не существует путь", $argument.FtpDirectory , "на сервере") }
    }
}
    
} # ********************************************************************************** </Function Blogging >