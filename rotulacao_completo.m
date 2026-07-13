close all
clear all
pkg load image
tic
im = imread('C:\Users\João Camilo\Dev\Codigos\PDI\C-digo-de-PDI\objetos.jpg');
figure('Name','Original')
imshow(im)

imMask = logical(zeros(size(im,1),size(im,2)));

for(i=1:size(im,1))
  for(j=1:size(im,2))
    if ((im(i,j,1)>10)&&(im(i,j,2)>10)&&(im(i,j,3)>10))
      imMask(i,j) = 1;
    end
  end
end

figure('Name','Máscara')
imshow(imMask)

imRotulada = uint8(imMask);

qtdErros = 1;

Rotulo = 2;

for(i=2:size(imMask,1)-1)
  for(j=2:size(imMask,2)-1)
    if(imMask(i,j)==1)
      vizinhos = [imRotulada(i-1,j-1), imRotulada(i-1,j), imRotulada(i-1,j+1), imRotulada(i,j-1)];
      distintos = unique(vizinhos);
      k=1;
      erros = 0;

      for(l=1:size(distintos,2))
        if(distintos(1,l)!=0)
          erros(1,k) = distintos(1,l);
          k = k + 1;
        end
      end

      if(size(erros,2)>1)
        matrizErros(qtdErros,1) = erros(1,1);
        matrizErros(qtdErros,2) = erros(1,2);
        qtdErros++;
      end
      if(imRotulada(i-1,j-1)!=0)
        imRotulada(i,j) = imRotulada(i-1,j-1);
      elseif(imRotulada(i-1,j)!=0)
        imRotulada(i,j) = imRotulada(i-1,j);
      elseif(imRotulada(i-1,j+1)!=0)
        imRotulada(i,j) = imRotulada(i-1,j+1);
      elseif(imRotulada(i,j-1)!=0)
        imRotulada(i,j) = imRotulada(i,j-1);
      else
        imRotulada(i,j) = Rotulo;
        Rotulo++;
      end

    end
  end
end

matrizErros = unique(matrizErros,"rows");

imFinal = imRotulada;

for(i=1:size(matrizErros,1))
  imFinal(imFinal==matrizErros(i,1)) = matrizErros(i,2);
endfor

qtdRegioes = size(unique(imFinal),1) - 1;
vRegiao = unique(imFinal);

for(i=1:qtdRegioes)
  imFinal(imFinal==vRegiao(i+1,1)) = i;
  vRegiao(i+1,1) = i;
end

figure('Name',['Imagem Final com ',num2str(qtdRegioes),' objetos'])
imshow(imFinal, [min(min(imFinal)) max(max(imFinal))])
tic
caracteristicas = zeros(2,qtdRegioes);
circ = zeros(1,3);
quad = zeros(1,3);
tri = zeros(1,3);


%Coisa nova
for(r=1:qtdRegioes)
  cimaI = 999;
  baixoI = 0;
  esquerdaJ = 999;
  direitaJ = 0;
  for(i=1:size(imFinal,1))
    for(j=1:size(imFinal,2))
      if(imFinal(i,j)==vRegiao(r+1,1))
        if(i<cimaI)
          cimaI = i;
        end
        if(i>baixoI)
          baixoI = i;
        end
        if(j<esquerdaJ)
          esquerdaJ = j;
        end
        if(j>direitaJ)
          direitaJ = j;
        end
      end
    end
  end
  for(i=1:baixoI-cimaI+1)
    for(j=1:direitaJ-esquerdaJ+1)
      objetoSeparado(i,j) = imFinal(cimaI+i-1,esquerdaJ+j-1);
    end
  end
  figure('Name','Objeto separado')
  imshow(objetoSeparado, [0 max(max(objetoSeparado))])
  areaObjeto = 0;
  perimetroObjeto = 0;

  for i = 1:size(objetoSeparado, 1)
    for j = 1:size(objetoSeparado, 2)
      if (objetoSeparado(i, j) == vRegiao(r+1, 1))
        areaObjeto = areaObjeto + 1;

        if (i == 1 || i == size(objetoSeparado, 1) || j == 1 || j == size(objetoSeparado, 2) || objetoSeparado(i-1, j) == 0 || objetoSeparado(i+1, j) == 0 || objetoSeparado(i, j-1) == 0 || objetoSeparado(i, j+1) == 0)
          perimetroObjeto = perimetroObjeto + 1;
        endif
      endif
    endfor
  endfor

  largura = direitaJ - esquerdaJ + 1;
  altura = baixoI - cimaI + 1;

  areaBoundingBox = largura * altura;

  razaoFrenteFundo = areaObjeto / areaBoundingBox;

  if (razaoFrenteFundo > 0.90)
      forma = 'Retangulo';
      caracteristicas(1,r) = 2;

  elseif (razaoFrenteFundo > 0.65)
      forma = 'Circulo';
      caracteristicas(1,r) = 1;

  else
      forma = 'Triangulo';
      caracteristicas(1,r) = 3;
  endif

  somaR = 0; somaG = 0; somaB = 0;

  for i = cimaI:baixoI
    for j = esquerdaJ:direitaJ
      if (imFinal(i, j) == vRegiao(r+1, 1))
        somaR = somaR + double(im(i, j, 1));
        somaG = somaG + double(im(i, j, 2));
        somaB = somaB + double(im(i, j, 3));
      endif
    endfor
  endfor

  mediaR = somaR / areaObjeto;
  mediaG = somaG / areaObjeto;
  mediaB = somaB / areaObjeto;

  cor = 'Indefinida';
  if (mediaR > mediaG && mediaR > mediaB)
    cor = 'Vermelho';
    caracteristicas(2,r) = 1;
  elseif (mediaG > mediaR && mediaG > mediaB)
    cor = 'Verde';
    caracteristicas(2,r) = 2;
  elseif (mediaB > mediaR && mediaB > mediaG)
    cor = 'Azul';
    caracteristicas(2,r) = 3;
  endif

  nomeArquivo = ['objeto ', num2str(r), ' ', forma, ' ', cor];

  imagemRecortadaColorida = im(cimaI:baixoI, esquerdaJ:direitaJ, :);

  for i = 1:size(objetoSeparado, 1)
    for j = 1:size(objetoSeparado, 2)
      if (objetoSeparado(i, j) == 0)
        imagemRecortadaColorida(i, j, 1) = 0;
        imagemRecortadaColorida(i, j, 2) = 0;
        imagemRecortadaColorida(i, j, 3) = 0;
      endif
    endfor
  endfor
  figure('Name', nomeArquivo);
  imshow(imagemRecortadaColorida);
##  imwrite(imagemRecortadaColorida, nomeArquivo);
  size(objetoSeparado)
  clear objetoSeparado
end
for(r=1:qtdRegioes);

  if(caracteristicas(1,r)==1) %Circulo
    if(caracteristicas(2,r)==1) %Vermelho
      circ(1,1) += 1;
    elseif(caracteristicas(2,r)==2) %Verde
      circ(1,2) += 1;
    else %Azul
      circ(1,3) += 1;
    endif

  elseif(caracteristicas(1,r)==2) %Retangulo
    if(caracteristicas(2,r)==1) %Vermelho
      quad(1,1) +=1;
    elseif(caracteristicas(2,r)==2) %Verde
      quad(1,2) +=1;
    else %Azul
      quad(1,3) +=1;
    endif
  elseif (caracteristicas(1,r)==3)%Triangulo
    if(caracteristicas(2,r)==1) %Vermelho
        tri(1,1) += 1;
      elseif(caracteristicas(2,r)==2) %Verde
        tri(1,2) += 1;
      else %Azul
        tri(1,3) += 1;
      endif

  endif
endfor
fprintf("\n===== Resumo =====\n");

fprintf("Total de objetos : ", qtdRegioes);
fprintf("Circulos:\n");
fprintf("  Vermelhos: %d\n", circ(1,1));
fprintf("  Verdes   : %d\n", circ(1,2));
fprintf("  Azuis    : %d\n\n", circ(1,3));

fprintf("Retangulos:\n");
fprintf("  Vermelhos: %d\n", quad(1,1));
fprintf("  Verdes   : %d\n", quad(1,2));
fprintf("  Azuis    : %d\n\n", quad(1,3));

fprintf("Triangulos:\n");
fprintf("  Vermelhos: %d\n", tri(1,1));
fprintf("  Verdes   : %d\n", tri(1,2));
fprintf("  Azuis    : %d\n", tri(1,3));

toc
