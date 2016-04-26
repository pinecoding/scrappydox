<#
Copyright (c) 2016 Sam Gabriel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

Param(
  [string]$file = '',
  [int]$sheet = 1,
  [string]$class = '',
  [switch]$markup,
  [switch]$sort
)

if ($file -eq '') {
    $cmdname = $MyInvocation.MyCommand.Name
    Write-Host "$cmdname file [sheet] [class] [markup] [sort]"
    Exit 1
}

<#
$Host.UI.WriteErrorLine("file $file")
$Host.UI.WriteErrorLine("sheet $sheet")
$Host.UI.WriteErrorLine("class $class")
#>

$file = [System.IO.Path]::GetFullPath($file)
$excel = New-Object -comobject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Open($file)
$worksheet = $workbook.Sheets.Item($sheet)
$cells = $worksheet.Cells
$usedRange = $worksheet.UsedRange
$colCount = $usedRange.Columns.Count
$colFirst = $usedRange.Column
$colLast = $colFirst + $colCount - 1
$rowCount = $usedRange.Rows.Count
$rowFirst = $usedRange.Row
$rowLast = $rowFirst + $rowCount - 1
if ($markup) {
    Write-Host "|="
}
elseif ($class) {
    Write-Host "<table class=`"$class`">"
}
else {
    Write-Host '<table>'
}
for ($row = $rowFirst; $row -le $rowLast; $row++) {
    $line = '<tr>'
    $type = 'td'
    if ($row -eq $rowFirst) {
        $type = 'th'
    }
    elseif ($markup) {
        Write-Host "|-"
    }
    [int]$outcol = 0
    for ($col = $colFirst; $col -le $colLast; $col++) {
        $item = $cells.Item($row, $col)
        $colorIndex = $item.Interior.ColorIndex
        [int]$rgb = $item.Interior.Color
        $hexRgb = "{0:X6}" -f $rgb
        $hexB = $hexRgb.Substring(0,2)
        $hexG = $hexRgb.Substring(2,2)
        $hexR = $hexRgb.Substring(4,2)
        $hexRgb = '#' + $hexR +$hexG + $hexB
        $style = ''
        if ($colorIndex -ne -4142) {
            #$Host.UI.WriteErrorLine("$row $col $colorIndex ($hexRgb)")
            $style = " style=`"background-color: $hexRgb`""
        }
        $content = $item.Text
        $line += '<' + $type + $style + '>'
        if ($markup) {
            if ($row -eq $rowFirst) {
                Write-Host "|# $content"
            }
            else {
                Write-Host "|| $content"
            }
        }
        elseif (($row -eq $rowFirst) -and $sort) {
            $line += '<button href="" onclick="' + "sort(this.parentNode.parentNode.parentNode.parentNode," +  $outcol + ")" + '">'
            $line += $content
            $line += "</button>" 
        }
        else {
            $line += $content
        }
        $line += '</' + $type + '>'
        $outcol++
    }
    $line += '</tr>'
    if (-not $markup) {
        Write-Host $line
    }
}
if ($markup) {
    Write-Host "|_"
}
else {
    Write-Host '</table>'
}

$workbook.Close()
$excel.Quit()
$rv = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel);


