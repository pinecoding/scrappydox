<#
Copyright (c) 2015 Sam Gabriel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

if ($Args.length -ne 2) {
    $cmdname = $MyInvocation.MyCommand.Name
    Write-Host "$cmdname infile outfile"
    Exit
}
#Write-Host $Args[0];
#$curdir = Split-Path $MyInvocation.MyCommand.Path
#$fileIn = $curdir + '\' + $Args[0]
#$fileOut = $curdir + '\' + $Args[1]
$fileIn = [System.IO.Path]::GetFullPath($Args[0])
$fileOut = [System.IO.Path]::GetFullPath($Args[1])
#Write-Host $fileIn
#Get-Content "README.txt"
#Exit
$excel = New-Object -comobject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Open($fileOut)
$sheet = $workbook.Sheets.Item(1)
$cells = $sheet.Cells
$usedRange = $sheet.UsedRange
$colCount = $usedRange.Columns.Count
$colFirst = $usedRange.Column
$colLast = $colFirst + $colCount - 1
$rowCount = $usedRange.Rows.Count
$rowFirst = $usedRange.Row
$rowLast = $rowFirst + $rowCount - 1
#Write-Host "$colCount columns, $colFirst to $colLast"
for ($row = $rowFirst; $row -le $rowLast; $row++) {
    for ($col = $colFirst; $col -le $colLast; $col++) {
        $content = $cells.Item($row, $col).Text
        $content = $content -replace '<#([^#]*\^)?(.+)#>', '$2'
        $content = $content -replace '^`(.+)`$', '$1'
        $cells.Item($row, $col) = $content
    }
}
$workbook.Save()
$workbook.Close()
$excel.Quit()
$rv = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel);
