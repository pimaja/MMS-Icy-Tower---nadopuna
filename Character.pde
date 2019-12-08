
// Klasa sa kojom pokrecemo lika i u kojoj su spremljeni njeni podaci
class Character {

    private float posx, posy;
    private float vx=0, vy=0;
    private float ax=.3, ay=1.1, startingJump = 15;
    private PImage sprite;
    private int run = 0, ledge = 0, standing = 0, rotation = 0;
    private boolean onGround=false, jumpedFromPlatform=false, firstLanding=false, isInCombo=false, newRecord = false;
    private Screen screen;
    String character;
    private HashMap<String, PImage> sprites = new HashMap<String, PImage>();
    private int currentPlatformIndex, currentPlatformNumber, previousPlatformNumber, comboCount, comboTimer = 0, highestCombo = 0;
    private float startingJumpSpeed;
    Leaderboards lboards;

    Character( Screen scr, String _character, Leaderboards _lboards)
    {
        screen = scr;
        lboards = _lboards;
        posx = (screen.getScreenStart() + screen.getScreenEnd())/2-30;
        posy = height-55;
        character = _character;
        loadSprites();
        sprite = sprites.get("jumping");
    }

    void loadSprites()
    {
        sprites.put("jumping", loadImage(character + "-jumping.png"));
        sprites.put("jumping-right", loadImage(character + "-jumping-right.png"));
        sprites.put("jumping-left", loadImage(character + "-jumping-left.png"));
        sprites.put("jumping-top-right", loadImage(character + "-jumping-top-right.png"));
        sprites.put("jumping-top-left", loadImage(character + "-jumping-top-left.png"));
        sprites.put("falling-right", loadImage(character + "-falling-right.png"));
        sprites.put("falling-left", loadImage(character + "-falling-left.png"));
        sprites.put("combo", loadImage(character + "-combo.png"));
        for (int i = 0; i < 4; ++i)
        {
            sprites.put("run-" + str(i) + "-left", loadImage(character + "-run-" + str(i) + "-left.png"));
            sprites.put("run-" + str(i) + "-right", loadImage(character + "-run-" + str(i) + "-right.png"));

            if (i < 3) // Standing nema 3
            {
                sprites.put("standing-" + str(i), loadImage(character + "-standing-" + str(i)+ ".png"));
            }
            if (i < 2) // Ledge nema 2 i 3
            {
                sprites.put("left-ledge-" + str(i), loadImage(character + "-left-ledge-" + str(i) + ".png"));
                sprites.put("right-ledge-" + str(i), loadImage(character + "-right-ledge-" + str(i) + ".png"));
            }
        }
    }

    void setSprite()
    {
        // Crta "combo" sprite i rotira ga ako smo unutar comboa i brzo se krecemo i uz to smo skocili, a ne pali, sa platforme
        if(isInCombo && abs(startingJumpSpeed) >= 30 && jumpedFromPlatform) 
        {
            sprite = sprites.get("combo");
            pushMatrix();
            translate(posx, posy);
            rotation = (rotation + 10) % 360;
            rotate(map(rotation, 0, 360, 0, 2*PI));
            image(sprite,0,0);
            popMatrix();
            sprite.resize(0, 70);
        }
        else
        {
            if (onGround)
            {
                if (abs(vx) < 1) // Ako je na zemlji i ne krece se
                {

                    // Ako je igrac na rubu platforme
                    int isPlayerOnLedge = screen.getPlatforms().get(currentPlatformIndex).isOnLedge(this);
                    if (abs(isPlayerOnLedge) == 1)
                    {
                        String image = "-ledge-"+str(ledge/10);
                        ledge = (ledge+1)%20; // Mijenjamo sprite za rub svako 10 frameova
                        image = ((isPlayerOnLedge == -1) ? "left" : "right") + image;
                        sprite = sprites.get(image);
                        ledgeaudio.play();
                    } else
                    {
                        ledgeaudio.rewind();
                        sprite = sprites.get("standing-"+str(standing/20));
                        standing = (standing+1)%60; // Mijenjamo sprite za stajanje svako 20 frameova
                    }
                } else
                {
                    String image = "run-"+str(run/10);
                    run = (run+1)%40; // Mijenjamo sprite za trcanje svako 10 frameova
                    image += (vx < 0) ? "-left" : "-right";
                    sprite = sprites.get(image);
                }
            } else
            {
                if (abs(vx) < 1) // Ako se ne krece desno ili lijevo
                {
                    sprite = sprites.get("jumping");
                } else
                {

                    if (abs(vy) < 3) // Ako leti i u vrhu je skoka
                    {
                        sprite = sprites.get("jumping-top" + ( (vx < 0) ? "-left" : "-right") );
                    } else
                    {
                        String image = (vy < 0) ? "jumping" : "falling";
                        image += (vx < 0) ? "-left" : "-right";
                        sprite = sprites.get(image);
                    }
                }
            }
            sprite.resize(0, 70);
            image(sprite, posx, posy);
        }

    }

    void pauseScreen()
    {
        image(sprite, posx, posy);

        drawCombo();
    }


    void move()
    {
        horizontalMovement();
        verticalMovement();

        keepInScreen();
        setSprite();

        drawCombo();

    }

    void drawCombo()
    {
        // Crtamo counter za combo ako se desava combo
        if(comboCount > 0)
        {
            textWithOutline(str(comboCount) + "\n FLOORS!", 50, 270, color(var, 255, 255), 24);
        }


        // Crtamo bar za combo
        fill(#800040);
        rect(15, 35, 40, 210, 10);
        fill(0);
        rect(25, 50, 20, 180, 10);
        fill(#fd4102);
        rect(25, 50 + 180 - comboTimer, 20, comboTimer, 8);

        // Trenutni najveci combo
        textWithOutline("Best\ncombo:\n" + str(round(highestCombo)), 60, 550, color(var, 255, 255), 25);

    }

    void horizontalMovement()
    {
        // Horizontalne kretnje
        if (leftKeyPressed)
        {
            vx -= (vx > 0) ? 4*ax : ax; // Ako se vec krece desno onda da se malo brze krece prema lijevo pa da brze uspori
        }
        if (rightKeyPressed)
        {
            vx += (vx < 0) ? 4*ax : ax;
        }
        if (onGround && !leftKeyPressed && !rightKeyPressed)
        {
            vx *= 0.9; // Usporavanje ako se ne krece
        }

        vx = constrain(vx, -20, 20);
        posx += vx;

    }

    void verticalMovement()
    {
        // Vertikalne kretnje (skakanje)
        if (isOnGround())
        {
            vy=0;
            onGround=true;
            jumpedFromPlatform = false;
        } else
        {
            previousPlatformNumber = currentPlatformNumber;
            vy+=ay;
            onGround = false;
        }

        // Provjeravamo combo ovdje u slucaju da igrac odma odskoci od platforme pa cemo zabiljeziti tu platformu
        checkForCombo();
        //ako smo stisli space i nismo u letu nego smo na površini (kada je onGround true), onda skacemo
        if (spaceKeyPressed && onGround)
        {
            vy=- startingJump - abs(vx*1.1);  // Vertikalnu brzinu mijenjamo ovisno o horizontalnoj
            onGround=false;

            //zvuk skoka ovisi o broju preskočenih platformi
            if(abs(vy)<25)//preskočena jedna platforma
            {
              skok_jedna.play();
              if ( skok_jedna.position() == skok_jedna.length() )
              {
                skok_jedna.rewind();
              }
            }
            else if(abs(vy) < 30)//preskoceno dvije platforme
            {
              skok_nekoliko.play();
              if ( skok_nekoliko.position() == skok_nekoliko.length() )
              {
                skok_nekoliko.rewind();
              }
            }
            else  //preskoceno više platformi
            {
              skok_vise.play();
              if ( skok_vise.position() == skok_vise.length() )
              {
                skok_vise.rewind();
              }
            }

            previousPlatformNumber = currentPlatformNumber;
            startingJumpSpeed = vy; // Potrebno radi odabire sprite-a
            jumpedFromPlatform = true; // Oznacavamo da je skocio sa platforme a ne pao

            if (currentPlatformIndex >= 4 && screen.getLevel() == 0 ) // Ako prijedjemo cetvrtu platformu onda se ekran pocinje kretati i pali se timer
            {
                screen.setLevel(1);
            }
        }

        posy+=vy;

        // Uvijek se krecemo malo prema dolje u skladu sa brzinog ekrana
        posy += screen.getSpeed();
    }


    boolean checkForCombo() // Provjeravamo je li combo
    {
        // Sa wiki:
        // A combo ends when a player makes a jump which covers only one floor,
        // falls off a floor and lands on a lower floor,
        // or fails to make a jump within a certain time frame (about 3 seconds).
        if(currentPlatformNumber == previousPlatformNumber + 1 || previousPlatformNumber > currentPlatformNumber || comboTimer < 0 )
        {
          //ovdje staviti fju za provjeru koji zvuk ide oviso o broju comboCount
            koji_zvuk(comboCount);
            if(comboCount > highestCombo) highestCombo = comboCount;
            comboCount = 0;
            comboTimer = 0;
            isInCombo = false;
            return false;
        }

        if(onGround && firstLanding && currentPlatformNumber != previousPlatformNumber) // Zadnji uvjet pazi da nismo skocili na istu platformu
        {
            comboTimer = 180;
            firstLanding = false; // Pazi da ne bi skokove sa iste na istu platformu brojali
            comboCount += currentPlatformNumber - previousPlatformNumber;
        }
        else if(!onGround)
        {
            firstLanding = true;
        }

        if(comboCount != 0) // Timer za combo se ne mice ako nismo u combou
            comboTimer--;
        isInCombo = true;
        return true;
    }

    void keepInScreen()
    {
        //ako lik dođe ispod visine, gotovi smo
        if (posy>=height-sprite.height/2)
        {
          //zvuk za game over
          game_ending.play();
          if ( game_ending.position() == game_ending.length() )
            {
            game_ending.rewind();
            }
            newRecord = lboards.checkForHighScore(highestCombo, currentPlatformNumber);
            stanje=2;
        }

        //ako harold dođe do vrha, ne može ići više od toga (ostalo -10 jer u originalu on udje malo u strop al vuce ekran za sobom pa nema problema i izgleda prirodno)
        if (posy <= -10)
            posy=-10;

        // Treba nam jer su slike centrirane
        float spriteHalf = sprite.width/2;

        //moramo mu zabraniti i da iziđe izvan lijevih i desnih rubova
        posx = constrain(posx, screen.getScreenStart() + spriteHalf, screen.getScreenEnd()-sprite.width+spriteHalf);

        // Odbijaj lika od zidova
        if (posx - spriteHalf == screen.getScreenStart() || posx + sprite.width - spriteHalf == screen.getScreenEnd())
        {
            vx *= (-0.5);
        }
    }

    boolean isOnGround()
    {
        for ( Platform pl : screen.getPlatforms())
        {
            if (pl.isOnPlatform(this))
            {
                // Prvo spremamo index platforme na kojoj lik stoji tako da lako provjeravamo stoji li lik na rubu platforme ili ne
                player.setCurrentPlatformIndex(screen.getPlatforms().indexOf(pl));

                // Spremamo trenutnu platformu radi comoboa i broja katova koji su prijedjeni
                player.setCurrentPlatformNumber(pl.getPlatformNumber());
                return true;
            }
        }
        return false;
    }

    float getSpriteWidth()
    {
        return sprite.width;
    }

    float getSpriteHeight()
    {
        return 70;
    }

    float positionX()
    {
        return posx;
    }

    float positionY()
    {
        return posy;
    }

    void setPositionY(float position)
    {
        posy = position;
    }

    float verticalSpeed()
    {
        return vy+ay; // Dodajemo u ay jer nam je bitno gdje ce lik biti iduci frame tako da znamo hoce li sletiti na platformu
    }

    void setCurrentPlatformIndex(int platformNo)
    {
        currentPlatformIndex = platformNo;
    }

    void setCurrentPlatformNumber(int platformNo)
    {
        currentPlatformNumber = platformNo;
    }

    int getCurrentPlatformNumber()
    {
        return currentPlatformNumber;
    }

    int getHighestCombo()
    {
        return highestCombo;
    }

    boolean isThereANewRecord()
    {
        return newRecord;
    }

    //htjela bih napisati funkciju koja će primati comboCount i na temelju toga pustiti
    //odgovarajuci AudioPlayer
    void koji_zvuk(int combo)
    {
      if(4<=combo && combo<=6)
      {
        good.play();
        if ( good.position() == good.length() )
        {
          good.rewind();
        }
        mainScreen.comboWordSize = 60;
        mainScreen.napisi("Good!");
      }
      else if(7<=combo && combo<=14)
      {
        sweet.play();
        if ( sweet.position() == sweet.length() )
          {
          sweet.rewind();
          }
        mainScreen.comboWordSize = 70;
        mainScreen.napisi("Sweet!");
      }
      else if(15<=combo && combo<=24)
      {
        great.play();
        if ( great.position() == great.length() )
          {
          great.rewind();
          }
        mainScreen.comboWordSize = 80;
        mainScreen.napisi("Great!");
      }
      else if(25<=combo && combo<=34)
      {
        superb.play();
        if ( superb.position() == superb.length() )
          {
          superb.rewind();
          }
        mainScreen.comboWordSize = 90;
        mainScreen.napisi("Super!");
      }
      else if(35<=combo && combo<=49)
      {
        wow.play();
        if ( wow.position() == wow.length() )
          {
          wow.rewind();
          }
        mainScreen.comboWordSize = 100;
        mainScreen.napisi("WOW!");
      }
      else if(50<=combo && combo<=69)
      {
        amazing.play();
        if ( amazing.position() == amazing.length() )
          {
          amazing.rewind();
          }
        mainScreen.comboWordSize = 110;
        mainScreen.napisi("AMAZING!");
      }
      else if(70<=combo && combo<=99)
      {
        extreme.play();
        if ( extreme.position() == extreme.length() )
          {
          extreme.rewind();
          }
        mainScreen.comboWordSize = 120;
        mainScreen.napisi("EXTREME!");
      }
      else if(100<=combo && combo<=139)
      {
        fantastic.play();
        if ( fantastic.position() == fantastic.length() )
          {
          fantastic.rewind();
          }
        mainScreen.comboWordSize = 130;
        mainScreen.napisi("FANTASTIC!");
      }
      else if(140<=combo && combo<=199)
      {
        splendid.play();
        if ( splendid.position() == splendid.length() )
          {
          splendid.rewind();
          }
        mainScreen.comboWordSize = 140;
        mainScreen.napisi("SPLENDID!");
      }
      else if(combo>=199)
      {
        no_way.play();
        if ( no_way.position() == no_way.length() )
          {
          no_way.rewind();
          }
        mainScreen.comboWordSize = 150;
        mainScreen.napisi("NO WAY!");
      }


    }
}
