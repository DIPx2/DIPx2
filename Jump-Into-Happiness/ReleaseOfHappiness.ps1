<#
 .Synopsis
  List the contents a FTP folder.

 .Description
  Connect to a FTP site and list the contents

 .Parameter Site
  The site to connect to.

 .Parameter User
  The user name.

 .Parameter Password
  Password associated with FTP site.

 .Parameter FtpDirectory
  The Directory on FTP server
  
  .Parameter FtpfileName
  Filename or wildcard to display
 .Example
   # List the files that start with text in the pub folder
   Show-FtpFile -Site ftp.site.com -User bob -Password secure -FtpDirectory pub -FtpFileName "text*"

#>
function Show-FtpFile {
param(
    [Parameter(Mandatory=$true)]
    [string] $site,
    [Parameter(Mandatory=$true)]
    [string] $user,
    [Parameter(Mandatory=$true)]
    [string] $password,
    [string] $ftpDirectory = "/",
    [Parameter(Mandatory=$true)]
    [string] $ftpFileName
    )
 
       

  try
    {
        # Load FluentFTP .NET assembly
        Add-Type -Path "FluentFTP.dll"

        # Setup session options
        $client = New-Object FluentFTP.FtpClient($site)
	    $client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
	    $client.ValidateAnyCertificate = 0
	    $client.EncryptionMode = 0
        $client.Encoding = [System.Text.Encoding]::GetEncoding(1251)    
        $client.Connect()

		if ($ftpDirectory -ne "")
		{
			$client.SetWorkingDirectory($ftpDirectory)
		}          
		$currentDirectory = $client.GetWorkingDirectory()
        try
        {
            foreach ($item in $client.GetListing(""))
            {
				if ($item.Name -like $ftpFileName)
				{
					Write-Output "$item"
				}
            }
        }
        finally
        {
            # Disconnect, clean up
            $client.Disconnect()
        }
     
        
    }
    catch
    {
        Write-Output $_.Exception#|format-list -force
       
    }
}


<#
 .Synopsis
  Rename a file in an FTP folder.

 .Description
  Connect to a FTP site and lis the contents

 .Parameter Site
  The site to connect to.

 .Parameter User
  The user name.

 .Parameter Password
  Password associated with FTP site.

 .Parameter DirectoryName
  The Directory on FTP server
  
  .Parameter oldName
  Old filename
  
    .Parameter NewName
  New filename
  
 .Example
   # Rename a file from old file name to new filename
   Rename-File -Site ftp.site.com -User bob -Password secure -FtpDirectory pub -oldName "Readme.txt -newName Readme.done"

#>
function Rename-FtpFile {
param(
    [Parameter(Mandatory=$true)]
    [string] $site,
    [Parameter(Mandatory=$true)]
    [string] $user,
    [Parameter(Mandatory=$true)]
    [string] $password,
    [string] $ftpDirectory = "",
    [Parameter(Mandatory=$true)]
    [string] $oldName,
    [Parameter(Mandatory=$true)]
    [string] $newName
    )

  try
    {
        # Load FluentFTP .NET assembly
        Add-Type -Path "FluentFTP.dll"

        # Setup session options
        $client = New-Object FluentFTP.FtpClient($site)
	    $client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
	    $client.ValidateAnyCertificate = 0
	    $client.EncryptionMode = 0
        $client.Encoding = [System.Text.Encoding]::GetEncoding(1251)    
        $client.Connect()

        try
        {
            if ($ftpDirectory -ne "")
            {
                $client.SetWorkingDirectory($ftpDirectory)
            }          
            $currentDirectory = $client.GetWorkingDirectory()
            if ($currentDirectory -match '/$')
            {
                $oldPath = "$currentDirectory$oldName"
                $newPath = "$currentDirectory$newName"
            }
            else
            {
                $oldPath = "$currentDirectory/$oldName"
                $newPath = "$currentDirectory/$newName"
            }
            if ($client.FileExists($oldPath))
            {
                $result = $client.Rename($oldPath, $newPath)
                if ($result)
                {
                    Write-Output "$oldPath successfully renamed to $newPath"
                }
            }
            else
            {
                Write-Output "$oldPath is not found on server"
            }
        }
        finally
        {
            # Disconnect, clean up
            $client.Disconnect()
        }    
    }
    catch [Exception]
    {
      echo $_.Exception#|format-list -force
      
    }
}

<#
 .Synopsis
  Copy a file to an FTP folder.

 .Description
  Copy a file to an FTP folder.

 .Parameter Site
  The site to connect to.

 .Parameter User
  The user name.

 .Parameter Password
  Password associated with FTP site.

 .Parameter FtpDirectory
  The Directory on FTP server
  
  .Parameter fileName
  Filename to transfer
  
 .Example
   # Copy a file or group of fles to an FTP folder.
   Send-FtpFile -Site ftp.site.com -User bob -Password secure -FtpDirectory pub -fileName "Read*"

#>
function Send-FtpFile {
param(
    [Parameter(Mandatory=$true)] [string] $site,
    [Parameter(Mandatory=$true)] [string] $user,
    [Parameter(Mandatory=$true)] [string] $password,
    [Parameter(Mandatory=$true)] [string] $ftpdirectory,
    [Parameter(Mandatory=$true)] [string] $localPath,
    [Parameter(Mandatory=$true)] [string] $FtpFileName,
                                 [switch] $binary = $false
    )

  try
    {
        # Load FluentFTP .NET assembly
        Add-Type -Path "FluentFTP.dll"

        # Setup session options
        $client = New-Object FluentFTP.FtpClient($site)
	    $client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
	    $client.ValidateAnyCertificate = 0
	    $client.EncryptionMode = 0
        $client.Encoding = [System.Text.Encoding]::GetEncoding(1251)    
        

        if ($binary)
        {
            $dataType = "Binary"
        }
        else
        {
            $dataType = "ASCII"
        }
            
        $client.UploadDatatype = $dataType
        $client.Connect()
        if ($FtpFileName -notlike "*\*" )
        {
            $FtpFileName = Join-path $localPath $FtpFileName
        }
        $lclFile = Split-Path $FtpFileName -leaf
        $lclDir = Split-Path $FtpFileName -Parent
        try
        {
            if ($ftpdirectory -ne "")
            {
                $client.SetWorkingDirectory($ftpdirectory)
            }
            
            $currentDirectory = $client.GetWorkingDirectory()
            $wildFiles = [IO.Directory]::GetFiles($lclDir, $lclFile);
            $filesUploaded = $false
            foreach ($filePath in $wildFiles)
            {
                $fileOnly = Split-Path $filePath -leaf 
                if ($currentDirectory -match '/$')
                {
                    $ftpPath = "$currentDirectory$fileOnly"
                }
                else
                {
                    $ftpPath = "$currentDirectory/$fileOnly"
                }
                $result = $client.UploadFile($filePath, $ftpPath)
                $filesUploaded = $true
                Write-Output "$filePath successfully copied to $ftpPath"
            }
            if (!$filesUploaded)
            {
                Write-Output "No files matching $FtpFileName were found"
            }
        }
        finally
        {
            # Disconnect, clean up
            $client.Disconnect()
        }    
    }
    catch [Exception]
    {
      echo $_.Exception#|format-list -force
      
    }
}
<#
 .Synopsis
  Get a file from an FTP folder.

 .Description
  Connect to a FTP site and lis the contents

 .Parameter Site
  The site to connect to.

 .Parameter User
  The user name.

 .Parameter Password
  Password associated with FTP site.

 .Parameter FtpDirectory
  The Directory on FTP server
  
  .Parameter FtpfileName
  Filename to transfer
  
 .Example
   # Get a file from FTP
   Get-FtpFile -Site ftp.site.com -User bob -Password secure -FtpDirectory pub -ftpfileName "Read*"

#>
function Get-FtpFile {
param(
    [Parameter(Mandatory=$true)] [string] $site,
    [Parameter(Mandatory=$true)] [string] $user,
    [Parameter(Mandatory=$true)] [string] $password,
    [Parameter(Mandatory=$true)] [string] $ftpFileName,
    [Parameter(Mandatory=$true)] [string] $localPath,
    [string] $ftpDirectory = "",
    [switch] $binary = $false
    )

  try
    {
        # Load FluentFTP .NET assembly
        Add-Type -Path "FluentFTP.dll"

        # Setup session options
        $client = New-Object FluentFTP.FtpClient($site)
	    $client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
	    $client.ValidateAnyCertificate = 0
	    $client.EncryptionMode = 0
        $client.Encoding = [System.Text.Encoding]::GetEncoding(1251)    
        

        if ($binary)
        {
            $dataType = "Binary"
        }
        else
        {
            $dataType = "ASCII"
        }
            
        $client.DownloadDatatype = $dataType
        $client.Connect()

        try
        {
            if ($ftpdirectory -ne "")
            {
                $client.SetWorkingDirectory($ftpDirectory)
            }
            
            $currentDirectory = $client.GetWorkingDirectory()  
            $filesDownloaded = $false            
            foreach ($item in $client.GetListing(""))
            {
                $fileonly = $item.Name
                $localFile = Join-path $localPath $fileOnly
                if ($item.Name -like $ftpFileName)
				{
					if ($client.DownloadFile($localFile, $fileOnly))
					{
                        $filesDownloaded = $true
						Write-Output ("$fileOnly successfully downloaded to $localFile" )
					}
					else
					{
						Write-Output ("Unable to download $fileOnly to $localFile" )
					}
				}
            }
            if (!$filesDownloaded)
            {
                Write-Output "Attempting to download files matching $ftpFileName. No files were found"
            }
        }    
        finally
        {
            # Disconnect, clean up
            $client.Disconnect()
        }            
    }
    catch [Exception]
    {
      echo $_.Exception#|format-list -force
      
    }
}
<#
 .Synopsis
  Delete a file from an FTP folder.

 .Description
  Connect to a FTP site and lis the contents

 .Parameter Site
  The site to connect to.

 .Parameter User
  The user name.

 .Parameter Password
  Password associated with FTP site.

 .Parameter FtpDirectory
  The Directory on FTP server
  
  .Parameter ftpfileName
  Filename to delete
  
 .Example
   # Delete a file or files from an FTP folder
   Remove-FtpFile -Site ftp.site.com -User bob -Password secure -FtpDirectory pub -ftpfileName "Read*"

#>
function Remove-FtpFile {
param(
    [Parameter(Mandatory=$true)]
    [string] $site,
    [Parameter(Mandatory=$true)]
    [string] $user,
    [Parameter(Mandatory=$true)]
    [string] $password,
    [string] $ftpDirectory = "",
    [Parameter(Mandatory=$true)]
    [string] $ftpFileName
    )

  try
    {
        # Load FluentFTP .NET assembly
        Add-Type -Path "FluentFTP.dll"

        # Setup session options
        $client = New-Object FluentFTP.FtpClient($site)
	    $client.Credentials = New-Object System.Net.NetworkCredential($user, $password)
	    $client.ValidateAnyCertificate = 0
	    $client.EncryptionMode = 0
        $client.Encoding = [System.Text.Encoding]::GetEncoding(1251) 
        $client.Connect()

        try
        {
            if ($ftpDirectory -ne "")
            {
                $client.SetWorkingDirectory($ftpDirectory)
            }
            $filesDeleted = $false         
            foreach ($item in $client.GetListing(""))
            {
                $fileOnly = $item.Name
				if ($fileonly -like $ftpFileName)
				{
                    $filesDeleted = $true
					$success = $client.DeleteFile($fileOnly)
					Write-Output "$fileOnly successfully deleted"
				}
            }
            if (!$filesDeleted)
            {
                Write-Output "No files matching $ftpFileName were found on the FTP server"
            }
        }    
        finally
        {
            # Disconnect, clean up
            $client.Disconnect()
        }            
    }
    catch [Exception]
    {
      echo $_.Exception#|format-list -force
      
    }
}

#******************************************************************************************************************************    



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


Function EmitterIP{
param( [Parameter(Mandatory=$true)] [string] $site )
try{ Test-Connection -Protocol DCOM -ComputerName $site -Count 2 | Out-Null
     Write-Output $true 
    } catch {Write-Output $false}
} #********************************************************************************************
Function Run-Give {

param(  [Parameter(Mandatory=$true)] [string] $Site,
        [Parameter(Mandatory=$true)] [string] $User,
        [Parameter(Mandatory=$true)] [string] $Password,
        [Parameter(Mandatory=$true)] [string] $FtpDirectory,
        [Parameter(Mandatory=$true)] [string] $localPath,
        [Parameter(Mandatory=$true)] [string] $LocalFilePattern
)

$report = @()
# 4 - Локальный каталог не существует
if ( (Test-Path -Path $localPath) -eq $false ) { return $report += ( "4"+"|"+"*" ) }
$dump = Get-ChildItem -Path $localPath -Name -File
# 8 - Нет файлов в каталоге отправки
if ( $dump.Length -eq 0 ) { return $report += ( "8"+"|"+"*" ) }
    foreach ( $I in $dump ){
        if ($I.trim() -match $LocalFilePattern){ 
            $xf = Send-FtpFile  -Site $Site `
                                -User $User `
                                -Password $Password `
                                -FtpDirectory $FtpDirectory `
                                -localPath $LocalPath `
                                -FtpFileName $I.Trim()
            
            if ( $xf -match "successfully copied") { 
                 Remove-Item -Path  ( Join-Path $localPath $I )
                 $report += ( "12"+"|"+ $i)  # 12 - Отправка из локального каталога на FTP произошла
            }

        } else {
            # 16 - Файл в каталоге отправки не соответствует шаблону отправки
            $report += ( "16"+"|"+ $i )        }
    }

return $report
} #********************************************************************************************

	Function Get-List_FILES { Param ([Parameter(Mandatory=$true)] [string[]] $Dump) 

		$u = @()

		foreach ($str in $dump){

			if ($str -match "^FILE"){
				$u += ($str | % { $_ -replace 'FILE\s{0,}' } | % { $_ -replace '\s{0,}\(.{0,}' })
			}
		}
		return $u

	}


Function Run-Get {

param(  [Parameter(Mandatory=$true)] [string] $Site,
        [Parameter(Mandatory=$true)] [string] $User,
        [Parameter(Mandatory=$true)] [string] $Password,
        [Parameter(Mandatory=$true)] [string] $FtpDirectory,
        [Parameter(Mandatory=$true)] [string] $FTPFile,
        [Parameter(Mandatory=$true)] [string] $localPath
)






	$report = @()


	# 4 - Локальный каталог не существует
	if ( (Test-Path -Path $localPath) -eq $false ) { return $report += ( "4"+"|"+"*" ) }

	$BigDump = Show-FtpFile -Site $Site -User $User -Password $Password -FtpDirectory $FtpDirectory -ftpFileName "*"

	if ( $BigDump -match "no such file or directory" ) { return $report += ( "52"+"|" +"*") }
	if ( $BigDump -match "Login or Password incorrect." ) { return $report += ( "20"+"|"+"*" ) }
	if ( $BigDump -match "Timed out trying to connect!" ) { return $report += ( "24"+"|" +"*") }

	if ( $BigDump.Count -gt 0 ){
		$OnlyFILE = Get-List_FILES -Dump ( $BigDump )
	}

	# 28 - FTP-каталог без файлов 
	if ($OnlyFILE.count -eq 0){ return $report += ( "28"+"|"+"*" ) } 
		else  { foreach ( $j in $OnlyFILE ) {
					# 32 - Файл на FTP, соответствует шаблону получения
					#if ( $j.Trim() -notmatch $FTPFile ) { return $report += ( "32"+"|"+$j.Trim() ) }
					if ( $j.Trim() -notmatch $FTPFile ) { $report += ( "32"+"|"+$j.Trim() ) }
					if ( $j.Trim() -match $FTPFile ) {
						[string]$e = Get-FtpFile -site $Site -user $User -password $Password -ftpDirectory $FtpDirectory -ftpFileName $j.Trim() -LocalPath $localPath
						# 36 - Загрузка файла из каталога FTP-сервера в локальный каталог произошла
						if ($e -match "successfully downloaded to"){ $report += ( "36"+"|"+$j.Trim() ) }
						# 40 - Файл из каталога FTP-сервера в локальный каталог не может быть принят
						if ($e -match "No files were found"){ return $report += ( "40"+"|"+$j.Trim() ); continue }
						$q = Remove-FtpFile -site $Site -user $User -password $Password -ftpDirectory $FtpDirectory -ftpFileName $j.Trim()
						# 44 - Файл из каталога FTP-сервера удален после получения
						if ($q -match "successfully deleted"){ $report += ( "44"+"|"+$j.Trim() ) }
					} 
			   }
		 }
	Write-Output $report
}



 #********************************************************************************************
Function Relay_Tr { Param ( [Parameter(Mandatory=$true)] [xml] $abibas )


$TreasuryClientPatternRecive = ( "{0}{1}{2}{3}" -f "[emldv]", $abibas.ini.TreasuryClient.PayRegNum, "[0-9]*\.", $abibas.ini.TreasuryClient.TreasCode )
$TreasuryClientPatternSend = ( "{0}{1}{2}{3}" -f "[fpqhw]", $abibas.ini.TreasuryClient.TreasCode, "[0-9]*\.", $abibas.ini.TreasuryClient.PayRegNum )

    #----------
    $argument_3 = @{}
    $report_3 = Run-Get  -Site $abibas.ini.FTP_Sever.IP_FTP`
                         -User $abibas.ini.FTP_Sever.FTPUserName`
                         -Password $abibas.ini.FTP_Sever.FTPUserPassword`
                         -FtpDirectory $abibas.ini.TreasuryClient.FTPDIRout`
                         -localPath $abibas.ini.TreasuryClient.MailIn`
                         -FTPFile $TreasuryClientPatternRecive
                         

    $argument_3.add( "localPath", $abibas.ini.TreasuryClient.MailIn )
    $argument_3.add( "FtpDirectory", $abibas.ini.TreasuryClient.FTPDIRout )
    $argument_3.add( "Description", "IT" ) # инфо-файл для Клиента-ТК

    Blogging -event $report_3 -argument $argument_3

    #----------
    $argument_2 = @{}
    $report_2 = Run-Get  -Site $abibas.ini.FTP_Sever.IP_FTP`
                         -User $abibas.ini.FTP_Sever.FTPUserName`
                         -Password $abibas.ini.FTP_Sever.FTPUserPassword`
                         -FtpDirectory $abibas.ini.TreasuryClient.FTPDIRout`
                         -FTPFile "[CLTK][0-9]*\.UPD"`
                         -localPath $abibas.ini.TreasuryClient.MailIn

    $argument_2.add( "localPath", $abibas.ini.TreasuryClient.MailIn )
    $argument_2.add( "FtpDirectory", $abibas.ini.TreasuryClient.FTPDIRout )
    $argument_2.add( "Description", "UT" ) # обновление для Клиента-ТК

    Blogging -event $report_2 -argument $argument_2
    #----------
    $argument_A = @{}
    $report_A = Run-Give    -Site $abibas.ini.FTP_Sever.IP_FTP`
                            -User $abibas.ini.FTP_Sever.FTPUserName`
                            -Password $abibas.ini.FTP_Sever.FTPUserPassword`
                            -FtpDirectory $abibas.ini.TreasuryClient.FTPDIRin`
                            -localPath $abibas.ini.TreasuryClient.MailOut`
                            -LocalFilePattern $TreasuryClientPatternSend

    $argument_A.add( "localPath", $abibas.ini.TreasuryClient.MailOut )
    $argument_A.add( "FtpDirectory", $abibas.ini.TreasuryClient.FTPDIRin )
    $argument_A.add( "Description", "TKi" ) # от Клиента-ТК

    Blogging -event $report_A -argument $argument_A
} #********************************************************************************************
Function Relay_Fi { Param ( [Parameter(Mandatory=$true)] [xml] $abibas )

$FinanceClientPatternRecive = ( "{0}-{1}-{2}{3}" -f $abibas.ini.FinanceClient.DistrictCode, $abibas.ini.FinanceClient.PayRegNumFin, $abibas.ini.FinanceClient.TreasAccNum,"[A-Za-z0-9]{0,5}\.que" ) 
$FinanceClientPatternSend = ( "{0}-{1}-{2}{3}" -f $abibas.ini.FinanceClient.DistrictCode, $abibas.ini.FinanceClient.TreasAccNum, $abibas.ini.FinanceClient.PayRegNumFin, "[A-Za-z0-9]{0,5}\.que" )

$FMpth = ( Get-ChildItem -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ |`
           where {$_.Name -match "Приложение Комплекс задач «Главный распорядител" } |`
           Get-ItemProperty ).'Inno Setup: App Path'

if ( $FMpth -like "" ) { Blogging -event "48|*" }

    #----------
    $argument_0 = @{}
    $report_0 = Run-Get  -Site $abibas.ini.FTP_Sever.IP_FTP`
                         -User $abibas.ini.FTP_Sever.FTPUserName`
                         -Password $abibas.ini.FTP_Sever.FTPUserPassword`
                         -FtpDirectory $abibas.ini.FinanceClient.FTPDIRout`
                         -localPath $abibas.ini.FinanceClient.MailIn`
                         -FTPFile $FinanceClientPatternRecive
                         

    $argument_0.add( "localPath", $abibas.ini.FinanceClient.MailIn )
    $argument_0.add( "FtpDirectory", $abibas.ini.FinanceClient.FTPDIRout )
    $argument_0.add( "Description", "IG" ) # инфо-файл для ГРС

    Blogging -event $report_0 -argument $argument_0

    #----------
    $argument_1 = @{}
    $report_1 = Run-Get  -Site $abibas.ini.FTP_Sever.IP_FTP`
                         -User $abibas.ini.FTP_Sever.FTPUserName`
                         -Password $abibas.ini.FTP_Sever.FTPUserPassword`
                         -FtpDirectory $abibas.ini.FinanceClient.FTPDIRout`
                         -FTPFile "Update\d*\.rar"`
                         -localPath $abibas.ini.FinanceClient.MailIn

    $argument_1.add( "localPath", $abibas.ini.FinanceClient.MailIn )
    $argument_1.add( "FtpDirectory", $abibas.ini.FinanceClient.FTPDIRout )
    $argument_1.add( "Description", "UG" ) # обновление для ГРС

    Blogging -event $report_1 -argument $argument_1

    foreach ($b in  $report_1) { 
        if ($b.count -ne 0) { 
            if ( $FMpth -and $b.StartsWith("36") ) { Set-Location $FMpth; Start-Process -FilePath ( Join-Path $FMpth "Update.exe") -ArgumentList a }
        }
    } 

    #----------
    $argument_B = @{}
    $report_B = Run-Give -Site $abibas.ini.FTP_Sever.IP_FTP`
                         -User $abibas.ini.FTP_Sever.FTPUserName`
                         -Password $abibas.ini.FTP_Sever.FTPUserPassword`
                         -FtpDirectory $abibas.ini.FinanceClient.FTPDIRin`
                         -localPath $abibas.ini.FinanceClient.MailOut`
                         -LocalFilePattern $FinanceClientPatternSend

    $argument_B.add("localPath", $abibas.ini.FinanceClient.MailOut)
    $argument_B.add( "FtpDirectory", $abibas.ini.FinanceClient.FTPDIRin )
    $argument_B.add( "Description", "FMi" ) # из FM

    Blogging -event $report_B -argument $argument_B
    #----------

    Write-Output ""

} #********************************************************************************************

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
                    Write-Host ( "{0} {1} {2}" -f "`t`t", (Date), $y ) -ForegroundColor White
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
Function main { Param ( [Parameter(Mandatory=$true)] [string]$declaration )

$SoManyAbibases = Get-ChildItem -Path $PSScriptRoot -File -Name | where { ($_ -match "^abibas") -and ($_ -match "$xml") } 

foreach ( $abibasik in $SoManyAbibases ){

    [xml]$X = Get-Content -Path ( Join-Path $PSScriptRoot $abibasik )
    
    if ( (EmitterIP -site $x.ini.FTP_Sever.IP_FTP -ErrorAction Stop) -eq $false ){ 
        Write-Output ( "{0} {1} {2} {3} {4}" -f  "`n`t","Пинг с сервером", $x.ini.FTP_Sever.IP_FTP, "не проходит,", "сообщите об этом своему администратору." )
        Read-Host ("{0} {1}" -f "`n`t`t`t", "Закрыть окно - нажмите Enter") | Out-Null
        return 
    }

    Write-Output ( "{0} {1}{2} {3}" -f  "`n", $x.ini.DisplayName, ":", "`n")
    if ( ($X.ini.FinanceClient.Activate).ToUpper() -eq "ON" ) { Relay_Fi ( $x ) }
    if ( ($X.ini.TreasuryClient.Activate).ToUpper() -eq "ON" ) { Relay_Tr ( $x ) }
    if ( ($X.ini.TreasuryClient.Activate).ToUpper() -eq "OFF" -and ($X.ini.FinanceClient.Activate).ToUpper() -eq "OFF"  ) { Write-host ("Ик! Все блоки в абибасе выключены...") }
}

Write-host ("`n"+">>>> SOKOL-SOFT >>>>") -NoNewline
Read-Host ("{0} {1}" -f "`t", "Закрыть окно - нажмите Enter") | Out-Null

}

main -declaration ХуйВойне!