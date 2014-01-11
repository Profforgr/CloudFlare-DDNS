$r = Invoke-WebRequest http://www.mattfreitag.com/ip/
$r.Forms[0].Name = ["option"]
Invoke-RestMethod http://www.mattfreitag.com/ip/ -Body $r.Forms[0]