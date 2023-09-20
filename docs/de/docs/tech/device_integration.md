# Integration heterogener Messgeräte

Wie im [Hintergrund](../background.md) beschrieben, sind Messsysteme, mit denen am 
Fahrzeug Daten generiert werden, kein direkter Teil des AW4.0 Hubs.  
Stattdessen sollen Daten auf dem Hub in einheitlichem Format vorliegen, damit
die KI basierte Verwertung unabhängig vom Messsystem möglich ist und auch die
Datenraumanbindung einfach standardisierbar ist.  
Hinzu kommt, dass der hier vorgestellte Prototyp eher auf einen stationären,
Server-seitigen Betrieb ausgerichtet ist.

Funktionalität zum hochladen und empfangen von Messungen ist daher essentiell,
damit überhaupt Fahrzeugdaten in das System gelangen können.

Um diese Funktionalitäten bereitzustellen sind zwei prinzipielle Ansätze vorgesehen,
die als *Hub-seitige Messsystemintegration* bzw. *Messsystem-seitige Hubintegration*
bezeichnet werden können.  
Diese Ansätze werden im Folgenden anhand von Beispielszenarien beschrieben.

## Ansatz 1: Hub-seitige Messsystemintegration

*Szenario*:  
Eine Werkstatt nutzt ein bestimmtes proprietäres Messystem zum Auslesen von 
Fehlercodes bzw. zum oszilloskopieren. Die Messsystemsoftware ermöglich es, 
Ergebnisse als Textdatei zu exportieren.  
Da das Messsystem weit verbreitet ist, beinhaltet die API des AW4.0 Hubs einen 
Endpunkt, der die exportierten Ergebnisse dieses Messsystems als Upload 
akzeptiert, in das Hub-interne Datenformat konvertiert und in der Datenbank 
speichert.  
Mitarbeiter der Werkstatt können also weiterhin die bekannte Software nutzen und 
die entstehenden Daten über die Weboberfläche des Hubs hochladen, so dass diese 
beispielsweise zur KI unterstützten Fehlerdiagnose verwertet werden können.


## Ansatz 2: Messsystem-seitige Hubintegration


*Szenario*:  
Eine Oszilloskop Hersteller möchte, dass die Kombination des eigenen Messsytems 
mit der AW4.0 Fehlerdiagnose möglichst einfach und anwenderfreundlich ist. 
In die eigene Messsoftware wird daher ein Client integriert, um direkt mit der 
Hub API zu kommunizieren.  
In der Benutzeroberfläche des Messsystems können nun die aktuell zu bearbeitenden 
Fälle angezeigt werden und insbesondere die von der KI erstellten „Messaufträge“.
Diese Aufträge können dann direkt mit dem Messsystem erledigt werden. Die 
entstandenen Daten werden automatisch an die Hub API geschickt, wo sie zur KI 
unterstützten Fehlerdiagnose verwertet werden können.
