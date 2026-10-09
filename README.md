# Twenty20
How to implement the 20-20-20 rule on your laptop device using a USB or other plugable devices to trigger the Twenty20 code that beeps every 20 minutes, twice at the start of the 20 seconds and three times at the end.


The idea I implemented is that any time you have a USB memory stick in your laptop, it with trigger an event and run the code automatically. It will give an initial beep so you know the timer has started, and then will function as required.


Complete set up as follows:

1. Identify USB hardware ID

input the following code into PowerShell

Get-PnpDevice -Class USB | Where-Object { $_.FriendlyName -like "*Mass Storage*" -or $_.FriendlyName -like "*Flash*" } | Select-Object FriendlyName, InstanceId
