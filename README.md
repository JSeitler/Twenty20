# Twenty20
How to implement the 20-20-20 rule on your laptop device using a USB or other plugable devices to trigger the Twenty20 code that beeps every 20 minutes, twice at the start of the 20 seconds and three times at the end.


The idea I implemented is that any time you have a USB memory stick in your laptop, it with trigger an event and run the code automatically. It will give an initial beep so you know the timer has started, and then will function as required.


Complete set up as follows:

1. Identify USB hardware ID

input the following code into PowerShell

- to open PowerShell, press windows and type Powershell to find

Get-PnpDevice -Class USB | Where-Object { $_.FriendlyName -like "*Mass Storage*" -or $_.FriendlyName -like "*Flash*" } | Select-Object FriendlyName, InstanceId

2. Save Code

Create a Folder C:\twenty20
save file into this folder

3. Run USB event log

press Window and X at the same time and run

wevtutil sl "Microsoft-Windows-DriverFrameworks-UserMode/Operational" /e:true

to enable device arrival events

4. Task Schedule

i. press Window and R at the same time, typing taskschd.msc and press Enter 
this opens the schedule window

// Taskschd.png

ii. create task

// createtask.png

iii. General: title twenty20_auto
and to only run when user logged on
 //general.png

iv. triggers:
// triggers_new

click new
begin task on event
log: Microsoft-Windows-DriverFrameworks-UserMode/Operational
source: DriverFrameworks-UserMode
Event ID: 2003

// on_event

v. actions tab
// actions_new
type in powershell.exe
and in arguments: -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\twenty20\twenty20.ps1"

vi. COnditions
// uncheck.png

uncheck boxes
and set to do not start new instants


vii. verification

type into powershell

Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" | Select-Object ProcessId, CommandLine

to check it has worked
