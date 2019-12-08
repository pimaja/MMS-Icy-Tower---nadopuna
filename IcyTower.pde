//stanje=0 će biti početni ekran
//stanje=1 je igra
//stanje=2 je game over screen
//stanje=3 je pause screen
//stanje=4 su instrukcije

import java.util.Iterator;
import java.util.Map;
import java.lang.*;
import ddf.minim.*;


int stanje = 0, var=0, currentLetter=0, pickedOption=0, currentMenuOptionsCount;
PFont icyFont, icyFontFill;
PImage bg, bg2, cursorHarold, instructionsImage;
Screen mainScreen;
Character player;
boolean leftKeyPressed = false, rightKeyPressed = false, downKeyPressed = false, upKeyPressed = false, spaceKeyPressed = false, enterReleased=true;
boolean usernameEntered = false;
String pickedCharacter = "Harold";
Leaderboards boards;
char[] username = new char[] {'A', 'A', 'A'};

Minim minim;
//popis mogućih sound datoteka
AudioPlayer amazing, extreme, fantastic, good, great, hurry_up, jo, no_way;
AudioPlayer novi_high_score, game_ending, power, skok_jedna, skok_vise, skok_nekoliko;
AudioPlayer in_game, splendid, superb, sweet, theme, try_again, wow, ledgeaudio, menu_option, menu_select ;


void setup()
{
    size(1100, 700);
    icyFont = createFont("RoteFlora.ttf", 32);
    icyFontFill = createFont("RoteFloraFill.ttf", 32);
    colorMode(HSB);
    noStroke();

    cursorHarold = loadImage("cursorHarold.png");
    cursorHarold.resize(40, 0);

    bg=loadImage("background.png");
    bg2=loadImage("background2.png");

    boards = new Leaderboards();
    minim= new Minim(this);

    //Inicijalizacija svih AudioPlayera
    amazing=minim.loadFile("amazing.wav");
    extreme=minim.loadFile("extreme.wav");
    fantastic=minim.loadFile("fantastic.wav");
    good=minim.loadFile("good.wav");
    great=minim.loadFile("great.wav");
    hurry_up=minim.loadFile("hurry_up.wav");
    jo=minim.loadFile("jo.wav");//postavljeno
    no_way=minim.loadFile("no_way.wav");
    novi_high_score=minim.loadFile("novi_high_score.wav");//postavljeno
    game_ending=minim.loadFile("game_ending.wav");
    power=minim.loadFile("power.wav");
    skok_jedna=minim.loadFile("skok_jedna.wav");
    skok_vise=minim.loadFile("skok_vise.wav");
    skok_nekoliko=minim.loadFile("skok_nekoliko.wav");
    in_game=minim.loadFile("in_game.mp3"); //ovo je pjesma u igri, postavljeno
    splendid=minim.loadFile("splendid_sala.wav");
    superb=minim.loadFile("super.wav");
    sweet=minim.loadFile("sweet.wav");
    theme=minim.loadFile("theme.mp3"); //ova ide na početni ekran, postavljeno
    try_again=minim.loadFile("try_again.wav");
    wow=minim.loadFile("wow.wav");
    ledgeaudio=minim.loadFile("ledge.wav");
    menu_option=minim.loadFile("menu_option.wav");
    menu_select=minim.loadFile("menu_select.wav");

}

void draw()
{
    if (stanje==0)
        startScreen();
    else if (stanje==1)
        gameScreen();
    else if (stanje==2)
        endScreen();
    else if (stanje==3)
        pauseScreen();
    else if (stanje==4)
        instructionsScreen();
}

// stanje je 0
void startScreen()
{
    // Da pise ispravno pri ponovnom vracanju u main menu
    if(pickedCharacter=="dave")pickedCharacter="Dave";
    if(pickedCharacter=="harold")pickedCharacter="Harold";

    bg.resize(width, height);
    background(bg);

    textAlign(LEFT);

    // Za mijenjanje boje
    var++;
    if (var>255)var=0;

    currentMenuOptionsCount = 4;

    textWithOutline("Play", 70, 1*height/12,                                 color(var, 255, 255), 40);
    textWithOutline("Character: <" + pickedCharacter + ">", 70, 2*height/12, color(var, 255, 255), 40);
    textWithOutline("Instructions", 70, 3*height/12,                         color(var, 255, 255), 40);
    textWithOutline("Exit ", 70, 4*height/12,                                color(var, 255, 255), 40);

    image(cursorHarold, 25, (pickedOption+1)*height/12 - 2*cursorHarold.height/3 - 10);

    textAlign(CENTER);
    rotate(PI/6);
    textWithOutline("ICY", 4*width/5, -height/2+40,       color(var, 255, 255), 130);
    textWithOutline("TOWER", 4*width/5, -height/2+200, color(var, 255, 255), 130);
    rotate(-PI/6);

    //ako smo na startScreen dosli iz pauze>ponovni odabir main menua, moramo zaustaviti in game pjesmu i pustiti theme
    if(in_game.isPlaying())
    {
        in_game.pause();
    }

    //puštamo theme beskonačno puta
    theme.play();
    if ( theme.position() == theme.length() )
    {
      theme.rewind();
      theme.play();
    }
    boards.drawOnStartScreen();

    if ( keyPressed && key == ENTER && enterReleased  )
    {
        enterReleased=false;
        playSelectSound();

        switch (pickedOption) {
            // Zapocni igru
            case 0:
                pickedCharacter = (pickedCharacter == "Dave") ? "dave" : "harold";
                mainScreen = new Screen();
                player = new Character(mainScreen, pickedCharacter, boards);
                stanje = 1;
                pickedOption = 0; // Resetiramo ga na nulu
            break;
            //Mijenjanje lika
            case 1:
                pickedCharacter = (pickedCharacter == "Harold") ? "Dave" : "Harold";
                return;
            // Instrukcije
            case 2:
                instructionsImage = loadImage("instructions.png");
                instructionsImage.resize(width, height);
                stanje = 4;
                return;
            // Exit ce uvijek biti zadnji na popisu
            default:
                myExit();
            break;
        }


    }
}

// stanje je 1
void gameScreen()
{
    imageMode(CENTER);
    background(#75a3a3);

    mainScreen.draw();

    player.move(); // U njemu pomicemo i crtamo

    mainScreen.moveScreen(player.positionY(), player.verticalSpeed());

    theme.pause();
    in_game.play();
    jo.play();
    if ( in_game.position() == in_game.length() )  //ako dođem do kraja, želim ponoviti pjesmu
    {
      in_game.rewind();
      in_game.play();
    }

    imageMode(CORNER);
}

// stanje je 2
void endScreen()
{
    background(#75a3a3);

    // Crtamo ekrane iza zadnjeg kao da je pauzirano
    mainScreen.pauseScreen();
    player.pauseScreen();

    fill(0, 200);
    rect(0, 0, width, height);

    fill(#800040);
    rect(width/6, 2*height/6 - 50, 4*width/6, 3*height/6, 16);

    textAlign(CENTER);
    textFont(icyFont);
    fill(color(var, 255, 255));
    var++;
    if (var>255)var=0;
    textSize(150);
    text("GAME OVER",  width/2, height/4);

    currentMenuOptionsCount = 3;

    textAlign(LEFT);
    textWithOutline("Play again", width/3, height/3+50,     color(var, 255, 255), 50);
    textWithOutline("Main menu", width/3, height/3+50 + 50, color(var, 255, 255), 50);
    textWithOutline("Exit", width/3, height/3+50 + 100,     color(var, 255, 255), 50);

    image(cursorHarold, width/3 - 45, (pickedOption)*50 + height/3+50 - 2*cursorHarold.height/3 - 10);

    textWithOutline("Best combo: " + str(round(player.getHighestCombo())) +
                    "\nBest floor: " + str(round(player.getCurrentPlatformNumber())), width/6 + 20, 4*height/6, 255, 35);

    textAlign(CENTER);

    in_game.pause();
    jo.close();


    // Provjerava ako ima rekord i onda otvara prozor za upis usernamea
    if(player.isThereANewRecord() && !usernameEntered)
    {
        novi_high_score.play();
        if(novi_high_score.position()==novi_high_score.length())
        {
          novi_high_score.pause();
        }

        fill(#800040);
        rect(width/7, height/7, 5*width/7, 5*height/7, 10);

        // Upisujemo username slovo po slovo
        char[] us = username.clone();
        if((frameCount/10)%2 == 0) us[currentLetter] = '_'; // Indikator za trenutno slovo koje odabiremo

        textWithOutline("NEW RECORD\nWrite your name:\n" + String.valueOf(us), width/2, 2*height/7, 255, 40);

        textWithOutline("combo: " + str(round(player.getHighestCombo())) + "\nfloor: " + str(round(player.getCurrentPlatformNumber())), 2*width/7, 4*height/7, 255, 35);

        // Dodaj rekord
        if (stanje == 2 && !usernameEntered && keyPressed && key == ENTER && enterReleased)
        {
            enterReleased=false;
            playSelectSound();
            usernameEntered = true;
            boards.addNewRecord(String.valueOf(username));
        }

        pickedOption = 0; // Osiguravamo da se cursor ne mice dok je otvoren prozor za combo
    }

    // Ako nema rekorda ili je vec upisan i ako odaberemo neku opciju na end screen
    if ((!player.isThereANewRecord() || usernameEntered) && keyPressed && key == ENTER && enterReleased)
    {
        novi_high_score.rewind();

        enterReleased=false;
        playSelectSound();

        if(pickedOption == currentMenuOptionsCount - 1) // Exit ce uvijek biti zadnja
        {
            myExit();
        }

        // Vrati se u main menu
        if(pickedOption == 1)
        {
            stanje = 0;
            pickedOption=0;
            return;
        }

        // Igraj opet
        reset();
        usernameEntered = false;
        pickedOption = 0;

    }

}

// stanje je 3
void pauseScreen()
{
    background(100);
    mainScreen.pauseScreen();
    player.pauseScreen();

    fill(0, 200);
    rect(0, 0, width, height);

    textWithOutline("PAUSED", width/2, 200, 255, 150);

    textWithOutline("Press 'R' to reset.", width/2, 400, 255, 50);
    textWithOutline("Press 'M' to go to main menu.", width/2, 500, 255, 50);
    textWithOutline("Press 'P' to continue.", width/2, 600, 255, 50);

    if (keyPressed && (key == 'r' || key == 'R'))
    {
        reset();
    } else if (keyPressed && (key == 'm' || key == 'M'))
    {
        stanje = 0; // Prebaci na main menu
    }

}

// stanje je 4
void instructionsScreen()
{
    image(instructionsImage, 0, 0);
    if(keyPressed && (key != ENTER || (key == ENTER && enterReleased))) // Na 'ENTER' se vrati u main menu
    {
        enterReleased = false;
        playSelectSound();
        stanje = 0;
    }

}

void myExit()
{
    boards.saveToFile();
    exit();
}

void reset() {
    mainScreen = new Screen();
    jo=minim.loadFile("jo.wav");

    player = new Character(mainScreen, pickedCharacter, boards);
    stanje = 1;
}

void playSelectSound()
{
    menu_select.play();
    if ( menu_select.position() == menu_select.length() )
    {
        menu_select.rewind();
    }
}

void textWithOutline(String message, float x, float y, int myColor, int size)
{
  // Crta se unutarnji dio prvo
  fill(myColor);
  textFont(icyFontFill);
  textSize(size);
  text(message, x, y);

  // 'Outline'
  fill(0);
  textFont(icyFont);
  textSize(size);
  text(message, x, y);
}

// Ako su pritisnute tipke za lijevo i desno, one su CODED pa moramo ovako
// izvršavati provjeru

void keyPressed() {
    char c = key;
    if (key==CODED)
    {
        if (keyCode==LEFT)
        {
            leftKeyPressed = true;
        }
        if (keyCode==RIGHT)
        {
            rightKeyPressed = true;
        }

        if(stanje == 1 || stanje == 3) return; // U stanjima 1 i 3 nema menija

        // Pomicanje odabira u meni-u
        if(keyCode==UP)
        {
            pickedOption = (pickedOption == 0) ? currentMenuOptionsCount - 1 : (pickedOption - 1) % currentMenuOptionsCount;
        }
        if(keyCode==DOWN)
        {
            pickedOption = (pickedOption + 1) % currentMenuOptionsCount;
        }

        // Mijenja odabir lika
        if(stanje == 0 && (keyCode==LEFT || keyCode==RIGHT) && pickedOption == 1)
        {
            pickedCharacter = (pickedCharacter == "Harold") ? "Dave" : "Harold";
            playSelectSound();
        }
        else if((stanje == 0 || stanje == 2) && (keyCode==UP || keyCode==DOWN || (stanje == 0 && (keyCode==LEFT || keyCode==RIGHT) && pickedOption == 1)) )
        {
            menu_option.play();
            if ( menu_option.position() == menu_option.length() )
            {
                menu_option.rewind();
            }
        }


    } else if (key == ' ')
    {
        spaceKeyPressed = true;
    } else if ((key == 'p' || key == 'P') && (stanje == 1 || stanje == 3)) // Pause screen on/off
    {
        stanje = (stanje == 1) ? 3 : 1;
    } else if (stanje == 2 && !usernameEntered && key!=ENTER) // Ako je rekord onda upis slova za username
    {
        username[currentLetter] = key;
        currentLetter = (currentLetter+1)%3;
    }
}

void keyReleased() {
    if (key==CODED)
    {
        if (keyCode==LEFT)
        {
            leftKeyPressed = false;
        }
        if (keyCode==RIGHT)
        {
            rightKeyPressed = false;
        }
    } else if (key == ' ')
    {
        spaceKeyPressed = false;
    }
    else if(key==ENTER)
    {
      enterReleased=true;
    }
}

//za crtanje zvjezdica
    void star(float x, float y, float radius1, float radius2, int npoints) {
      float angle = TWO_PI / npoints;
      float halfAngle = angle/2.0;
      beginShape();
      for (float a = 0; a < TWO_PI; a += angle) {
        float sx = x + cos(a) * radius2;
        float sy = y + sin(a) * radius2;
        vertex(sx, sy);
        sx = x + cos(a+halfAngle) * radius1;
        sy = y + sin(a+halfAngle) * radius1;
        vertex(sx, sy);
      }
      endShape(CLOSE);
    }
    void crtajzvjezdice(){
        for(int i=0; i<5; i++){ 
           fill(color(var, 255, 255));
           star(random(300, width-300), random(600,700)-i*70, 5, 10, 5);
           var+=20;
           if(var>=255)var=0;
        }
    }
