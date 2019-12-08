
// Klasa u kojoj su podatci o samim platformama po kojima lik skace
class Platform {

    private float x, y, w, h  = 40; // Parametri platforme
    private int platformNumber;

    Platform(float _x, float _y, float _w, int _platformNumber)
    {
        x = _x;
        y = _y;
        w = _w;
        platformNumber = _platformNumber;
    }

    int getPlatformNumber()
    {
        return platformNumber;
    }

    // Provjerava stoji li igrac na platformi
    boolean isOnPlatform(Character player)
    {
        if (player.verticalSpeed() < 0) return false; // Ako igrac ide prema gore onda ne pada na platformu


        if ( player.positionY() + player.getSpriteHeight()/2 >= y - player.verticalSpeed()  && // Hoce li igrac pasti na platformu u iducem frame-u
            player.positionY() + player.getSpriteHeight()/2  <= y &&  // Je li igrac iznad platforme?
            player.positionX() + player.getSpriteWidth()/2 >= x &&  // Je li desno rub igraca desno od lijevog ruba platforme
            player.positionX() - player.getSpriteWidth()/2 <= x + w ) // Je li lijevi rub igraca lijevo od desnog ruba platforme
        {
            player.setPositionY(y - player.getSpriteHeight()/2); // Postavljamo igraca na platformu
            return true;
        }

        return false;

    }

    // | -1 = lijevi rub | 0 = nije na rubu | 1 = desni rub |
    int isOnLedge(Character player)
    {
        if (player.positionX() - player.getSpriteWidth()/3 <= x + 10)     return -1;
        if (player.positionX() + player.getSpriteWidth()/3 >= x + w - 10) return 1;
        return 0;
    }

    boolean isOutOfBounds()
    {
        return (y > height);
    }

    void draw()
    {
        // Crtaj platfomu ovisno o kojem se katu radi
        if(platformNumber<100)
        {
          fill(#A9A9A9);
          rect(x, y, w, h, 8);

        }
        else if(platformNumber<200)//snijeznja platforma
        {
          int ost=(int)w%20;
          if(ost!=0)
          {
            w+=20;
            w-=ost;
          }

          fill(255);
          rect(x,y,w,5);
          fill(#A9A9A9);
          rect(x, y+5, w, 35);
          fill(255);
          for(int i=0; i<(w/20)-1; i++)
          {
            arc(x+3+i*20, y+5, 10, 24, 0, PI);
            arc(x+13+i*20, y+5, 10, 12, 0, PI);
          }
        }
        else if(platformNumber<300)//drvena platforma
        {
          stroke(#000000);
          fill(#993300);
          rect(x, y, w, 14, 8);
          stroke(#cc4400);
          line(x,y+7,x+w,y+7);
          stroke(#000000);
          fill(#993300);
          ellipse(x+w/6, y+20, 14,14);
          ellipse(x+5*w/6, y+20, 14,14);

        }
        else if(platformNumber<400) // Metalna  platforma
        {
          stroke(#000000);
          fill(#007a99);
          rect(x, y, w, 14, 8);
          stroke(#00a3cc);
          line(x,y+7,x+w,y+7);
          stroke(#008fb3);
          line(x, y+3, x+w,y+3);
          line(x, y+11, x+w,y+11);
          stroke(#000000);


        }
        else if(platformNumber<500) // Žvakaća guma
        {
          int ost=(int)w%18;
          if(ost!=0)
          {
            w+=18;
            w-=ost;
          }

          fill(#e60073);
          rect(x,y,w,10);

          fill(#e60073);
          for(int i=0; i<(w/18)-1; i++)
          {
            if(i==0)
            {
              ellipse(x+8,y+18,6,5);
            }
            arc(x+4+i*18, y+6, 9, 24, 0, PI);
            arc(x+14+i*18, y+6, 9, 12, 0, PI);
            stroke(#ff1a8c);
            line(x+3+i*18, y+3, x+6+i*18, y+3);
            stroke(0);

          }
        }
        else if(platformNumber<600) // Trokuti
        {
          fill(#cc33ff);
          for(int i=0; i<(w/10)-1; i++)
          triangle(x+i*10, y, x+i*10+10, y, x+i*10+5, y+10);
        }
        else
        {
          fill(#008000);
          rect(x, y, w, 20, 8);
        }

        // Na svaku desetu napisi broj platforme
        if (platformNumber % 10 == 0)
        {
            fill(#993300);
            rect(x + w/2 - 20, y + 2*h/3 - 15, 40, 40, 5);
            stroke(0);
            line(x + w/2 - 20, y + 2*h/3 - 15 + 10, x + w/2 + 20, y + 2*h/3 - 15 + 10);
            line(x + w/2 - 20, y + 2*h/3 - 15 + 20, x + w/2 + 20, y + 2*h/3 - 15 + 20);
            line(x + w/2 - 20, y + 2*h/3 - 15 + 30, x + w/2 + 20, y + 2*h/3 - 15 + 30);
            textFont(createFont("Arial Bold", 20));
            fill(255);
            text(str(platformNumber), x + w/2, y + 2*h/3 + 10);
        }
        if(platformNumber % 50 == 0 && platformNumber>0)
          crtajzvjezdice();
    }

    // Spusti platformu na ekranu
    void reduceHeight(float amount)
    {
        y += amount;
    }
}
