 local pozycje = {

{pos = {x=1029, y=1040, z=7}, tekst = "Arena"},

{pos = {x=1027, y=1040, z=7}, tekst = "Cassino"},
 
{pos = {x=1025, y=1040, z=7}, tekst = "Serpiente"},

{pos = {x=1023, y=1040, z=7}, tekst = "Tetris"},
{pos = {x=1021, y=1040, z=7}, tekst = "Futbol"},
{pos = {x=32366, y=32235, z=7}, tekst = "Trainers"},
{pos = {x=32366, y=32238, z=7}, tekst = "Juegos!"},
{pos = {x=32371, y=32239, z=7}, tekst = "Items!"},
{pos = {x=32369, y=32241, z=7}, tekst = "Welcome!!"},







{pos = {x=1003, y=991, z=7}, tekst = "Dp!"},







 



 

 
 }

		function onThink(interval, lastExecution)
			local kolor = TEXTCOLOR_TEAL   -- Jakim kolorem jest dany napis
			for i=1, #pozycje do
				doSendMagicEffect(pozycje[i].pos,28)
				doSendAnimatedText(pozycje[i].pos,pozycje[i].tekst,kolor)
			end
			return true
			end