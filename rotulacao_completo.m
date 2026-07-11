close all
clear all
pkg load image

im = imread('C:\Users\Cauã Fonseca\PDI\Imagens\objetos.jpg');
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

figure('Name','Imagem Rotulada')
imshow(imRotulada, [1, Rotulo])

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
  size(objetoSeparado)
  clear objetoSeparado
end

