#### Sima Alexandru 312CA

# Tema 1 - IOCLA

## Structura proiectului

- `main.c`: entry-point-ul programului: Se initializeaza vectorul de comenzi, se
  citesc senzorii din fisierul binar, apoi se citesc si se executa comenzile de
  la tastatura
- `io.c`: functii pentru operatii de input/output: citire comenzi, citire
  senzori din fisier, afisare senzori
- `utils.c`: functii cu caracter general (interschimbare pointeri, eliberare
  resurse etc.)
- `Makefile`: Contine retete pentru compilarea, arhivarea si testarea
  programului.

## Functionalitate

- Programul accepta urmatoarele comenzi:
  - `print`: afiseaza informatii despre senzorul dat ca parametru. Senzorii
    PMU au prioritate, asa ca, la momentul citirii fisierului de intrare, daca
    un senzor este de tip TYRE, acesta va fi adaugat la finalul vectorului de
    senzori, la final inversandu-se ordinea senzorilor TYRE, pentru a pastra
    ordinea in care au fost cititi.
    - `analyze`: Fiecare senzor are o lista de operatii de efectuat. Astfel,
      pentru senzorul dat se aplica pe rand operatiile asociate (fiind
      reprezentate de niste indecsi ai vectorului de operatii incarcat la
      inceputul programului).
    - `clear`: Parcurge toti senzorii si verifica daca sunt in parametrii
      normali. Daca nu, ii sterge, permuta senzorii de dupa acestia in vector,
      apoi redimensioneaza vectorul.
    - `exit`: dealoca resursele si inchide programul.
