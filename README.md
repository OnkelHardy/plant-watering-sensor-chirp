# plant-watering-sensor-chirp
Application and programming of the irrigation sensor Chirp.

Dieses ist ein Remix von http://www.thingiverse.com/thing:3360957
Beschreibung von Chirp ist ebenfalls auf https://github.com/Miceuz/PlantWateringAlarm und auf https://wemakethings.net/chirp/ zu finden.

Vielen Dank und Hochachtung an Albertas Mickėnas (Miceuz) für die Entwicklung des Chirp.

Meine Veröffentlichung ist unter https://www.thingiverse.com/thing:3806713 und https://github.com/OnkelHardy/plant-watering-sensor-chirp zu finden.

Da Chirp schon so gut beschrieben ist werde ich hier nur das notwendige erklären. Dieses ist meine erste Veröffentlichung zum Chirp, weitergehende Entwicklungen (Chirp mit WiFi, automatische Pflanzenbewässerung) werden erfolgen. Ich habe das Chirp ohne Änderungen übernommen, und in China erworben. Bei einer entsprechenden Suche auf eBay wird man da sehr schnell fündig.

In dieser Version von mir unterscheidet sich das Chirp in der Anwendung noch nicht vom Original. Man kann also entweder meine Software oder die Original-Software auf das Chirp speichern.

Chirp verwendet den ATtiny44A von Atmel. Das kommt mir sehr gelegen, da diese Controller seit vielen Jahren meine persönlichen Favoriten sind. Ich habe das Programm in Assembler geschrieben es ist im Ordner src/ zu finden, sowohl als Source als auch als HEX zu direkten brennen.

Funktion:
Nach einem Reset (Batterie einlegen oder Taste betätigen) wird zunächst die Feuchte gemessen bei dessen Unterschreitung Alarm gegeben werden soll. Das wird durch das abspielen einer Tonfolge bestätigt. Chirp sollte also in einer relativ trockenen Erde auf diese Weise kalibriert werden.
Nach der ersten Messung wird der WatchDog des Controllers aktiviert und der Controller wird für 8 Sekunden im Energiesparmodus schlafen gelegt. Bei jedem Aufwachen wird eine Warteschleife aktualisiert, und nach eingestellten 5 Minuten wird die Feuchte der Erde gemessen. Ist diese unterhalb der beim Reset gemessenen Schwelle, wird über den Speaker Alarm gegeben.
Die Übertragung von Daten ist in dieser Version nicht erforderlich und daher deaktiviert (StandAlone), sie wird erst in der nächsten Veröffentlichung benötigt und dort beschrieben.

Das Gehäuse des Chirp habe ich mit OpenSCAD entwickelt und steht im Ordner scad/ zur Verfügung. Die fertigen STL-Dateien können mit einem beliebigen 3D-Drucker gedruckt werden. Die OpenSCAD-Datei liegt ebenfalls bei, so können eigene Veränderungen vorgenommen werden.

Bilder zu meinem Chirp befinden sich im Ordner pics/

 ---------------------------

This is a remix of http://www.thingiverse.com/thing:3360957
Description of Chirp can also be found at https://github.com/Miceuz/PlantWateringAlarm and https://wemakethings.net/chirp/

Many thanks and respect to Albertas Mickėnas (Miceuz) for the development of Chirp.

My release can be found at https://www.thingiverse.com/thing:3806713 and https://github.com/OnkelHardy/plant-watering-sensor-chirp .

Since Chirp is already so well described, I will only explain what is necessary here. This is my first publication about the Chirp, further developments (Chirp with WiFi, automatic plant irrigation) will follow. I have taken over the Chirp without changes, and acquired it in China. With an appropriate search on eBay you will find it very quickly.

In this version of mine the Chirp does not differ yet in the application from the original. So you can either save my software or the original software on the chirp.

Chirp uses the ATtiny44A from Atmel. This is very convenient for me because these controllers have been my personal favorites for many years. I have written the program in assembler it can be found in the folder src/, both as source and as HEX to burn directly.

Function:
After a reset (insert the battery or press the button) the humidity is measured and an alarm is given. This is confirmed by playing a tone sequence. Chirp should therefore be calibrated in a relatively dry earth in this way.
After the first measurement the WatchDog of the controller is activated and the controller is put to sleep for 8 seconds in the energy saving mode. Each time you wake up, a waiting loop is updated and after 5 minutes the humidity of the earth is measured. If this is below the threshold measured during reset, an alarm is given via the speaker.
The transmission of data is not required in this version and therefore deactivated (StandAlone), it will only be required and described in the next release.

I developed the Chirp case with OpenSCAD and it is available in the scad/ folder. The finished STL files can be printed with any 3D printer. The OpenSCAD file is also included, so you can make your own changes.

Pictures for my chirp can be found in the folder pics/
