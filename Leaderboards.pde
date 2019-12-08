// Ljestvice najboljih rezultata
// Format je "placement floor combo player"
class Leaderboards {
    ArrayList< HashMap<String, String> > bestCombo = new ArrayList< HashMap<String, String> >(), bestFloor = new ArrayList< HashMap<String, String> >();
    int newCombo, newFloor, indexOfBestCombo, indexOfBestFloor;
    PFont myFont  = createFont("RoteFlora.ttf", 35), columnsFont = createFont("SansSerif", 15); ;

    // Ucitava podatke iz datoteke i sprema u listu tako da pristupamo npr drugom najboljem combu i njegovom imenu sa bestCombo.get(1).get("player")
    Leaderboards()
    {
        String[] lines = loadStrings("leaderboards.txt");
        for (int i = 1 ; i < lines.length; i++)
        {
            if(i < 6)
            {
                String[] values = lines[i].split(" ");
                bestCombo.add(new HashMap<String, String>());

                bestCombo.get(i-1).put("floor", values[1]);
                bestCombo.get(i-1).put("combo", values[2]);
                bestCombo.get(i-1).put("player", values[3]);
            } else if (i > 6)
            {
                String[] values = lines[i].split(" ");
                bestFloor.add(new HashMap<String, String>());

                bestFloor.get(i-7).put("floor", values[1]);
                bestFloor.get(i-7).put("combo", values[2]);
                bestFloor.get(i-7).put("player", values[3]);
            }
        }
    }

    boolean checkForHighScore(int highestCombo, int floor)
    {
        int br = 0; // Prati jesu li sruseni rekordi
        HashMap<String, String> el;

        // Ovdje spremamo indekse elemenata u ArrayList ciji su rekordi sruseni pa tako da znamo gdje ubaciti novi element tj. novi rekord 
        // (-1 znaci da nije srusen rekord u toj kategoriji)
        indexOfBestCombo = -1; 
        indexOfBestFloor = -1;

        // Provjerava jel srusen rekord za najveci combo
        for( int i = 0; i < bestCombo.size(); ++i)
        {
            el = bestCombo.get(i);
            if( highestCombo > Integer.parseInt(el.get("combo")))
            {
                indexOfBestCombo = i;
                newCombo = highestCombo;
                newFloor = floor;
                ++br;
                break;
            }
        }

        // Jel srusen rekord za najveci kat
        for( int i = 0; i < bestFloor.size(); ++i)
        {
            el = bestFloor.get(i);
            if( floor > Integer.parseInt(el.get("floor")))
            {
                indexOfBestFloor = i;
                newCombo = highestCombo;
                newFloor = floor;
                ++br;
                break;
            }
        }

        return (br > 0);

    }

    void addNewRecord(String newUsername)
    {
        HashMap<String, String> el;

        // Provjerava ako je srusen rekord i onda ubacuje element na indeks prvog rekorda koji je srusen i izbacuje zadnjeg sa ljestvice
        if(indexOfBestCombo >= 0)
        {
            int i = indexOfBestCombo;
            el = bestCombo.get(i);
            bestCombo.add(i, new HashMap<String, String>());

            bestCombo.get(i).put("floor", str(newFloor));
            bestCombo.get(i).put("combo", str(newCombo));
            bestCombo.get(i).put("player", newUsername);

            bestCombo.remove(bestCombo.size() - 1);
        }

        // Analogno kao gore ali rekordi za katove
        if(indexOfBestFloor >= 0)
        {
            int i = indexOfBestFloor;
            el = bestFloor.get(i);
            bestFloor.add(i, new HashMap<String, String>());

            bestFloor.get(i).put("floor", str(newFloor));
            bestFloor.get(i).put("combo", str(newCombo));
            bestFloor.get(i).put("player", newUsername);

            bestFloor.remove(bestFloor.size() - 1);
        }

    }



    // Format je "placement foor combo player"
    void saveToFile()
    {
        HashMap<String, String> el;
        String[] outputString = new String[12]; // Spremamo u 12 elemenata pa ce leaderboards.txt imat 12 redova

        outputString[0] = "Highest combo";
        for( int i = 0; i < 5; ++i)
        {
            el = bestCombo.get(i);
            outputString[i+1] = str(i+1) + ' ' + el.get("floor") + ' ' + el.get("combo") + ' ' + el.get("player");
        }

        outputString[6] = "Highest floor";
        for( int i = 0; i < 5; ++i)
        {
            el = bestFloor.get(i);
            outputString[i+7] = str(i+1) + ' ' + el.get("floor") + ' ' + el.get("combo") + ' ' + el.get("player");
        }

        saveStrings("leaderboards.txt", outputString);
    }

    void drawOnStartScreen()
    {
        HashMap<String, String> el;

        float textY = 5*height/7, comboX = 1*width/5, floorX = 3*width/5 + 50;
        float tempY;

        textAlign(LEFT);
        textFont(myFont);
        fill(255);
        text("Highest combo", comboX, textY);
        text("Highest floor", floorX, textY);

        textFont(columnsFont);
        text("PLACE  FLOOR          COMBO           DUDE", comboX, textY+20);
        text("PLACE  FLOOR          COMBO           DUDE", floorX, textY+20);

        textFont(myFont);
        fill(255);

        tempY = textY+50;
        for( int i = 0; i < 5; ++i)
        {
            el = bestCombo.get(i);
            text(str(i+1), comboX, tempY);
            text(el.get("floor"), comboX + 60, tempY);
            text(el.get("combo"), comboX + 160, tempY);
            text(el.get("player"), comboX+ 250, tempY);
            tempY += 35;
        }

        tempY = textY+50;
        for( int i = 0; i < 5; ++i)
        {
            el = bestFloor.get(i);
            text(str(i+1), floorX, tempY);
            text(el.get("floor"), floorX + 60, tempY);
            text(el.get("combo"), floorX + 160, tempY);
            text(el.get("player"), floorX+ 250, tempY);
            tempY += 35;
            }

        textAlign(CENTER); // Vracamo na CENTER radi ostalih tekstova


    }

}
