function f = gaussianf(sig_x, sig_y, m, n, alpha)

    if nargin<5
        alpha = 0;
    end
    
    [yy,xx] = meshgrid(0.5:1:m, 0.5:1:n);
    alpha = (alpha)*pi/180;

    % Rotasi
    ynew = (yy-m/2)*sin(alpha)+(xx-n/2)*cos(alpha);
    xnew = -(xx-n/2)*sin(alpha)+(yy-m/2)*cos(alpha);

    % Itung filter cell
    Gx = (1/(sig_x*sqrt(2*pi)))*exp(-((xnew).^2)/(2*sig_x^2));
    Gy = (1/(sig_y*sqrt(2*pi)))*exp(-((ynew).^2)/(2*sig_y^2));

    G  = Gx.*Gy;
    
    % Normalisasi
    f = G/sum(G(:));
end