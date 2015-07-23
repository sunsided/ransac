function [data] = random_data()

    % Zufallspunkte-Bereich
    N = 500;
    M = 300;
    
    % Geraden-Stützpunkte ermitteln
    vertical = rand() > 0.5;   
    if vertical
        A = [rand(); 0];
        B = [rand(); 1];
    else
        A = [0; rand()];
        B = [1; rand()];
    end

    % orthogonalen Vektor ermitteln
    C = [-A(2); A(1)];
    D = [-B(2); B(1)];
       
    ov = (C-D)/norm(C-D);
    center = 0.5*(A+B);
        
    % Gerade zeichnen
    if ~nargout
        hold off;
        plot([A(1) B(1)], [A(2) B(2)], 'g')
        hold on;
        plot(center(1), center(2), 'go');
        plot([center(1) center(1)+ov(1)], [center(2) center(2)+ov(2)], 'g:');
        axis square;
        xlim([0 1]);
        ylim([0 1]);
    end
    
    % Gerade mit Rauschen überlagern
    v = B-A;  
    c = v*rand(1,M)+A*ones(1,M);
    n = ov*0.025*randn(1,M);
    points = c + n;
    
    % Geradenpunkte zeichnen
    if ~nargout
        plot(points(1,:), points(2,:), '+');
    end
    
    % Rauschen erzeugen
    noise = rand(2, N);
   
    % Rauschen zeichnen
    if ~nargout
        plot(noise(1,:), noise(2,:), 'b+');
    end
    
    data = [noise, points];

end