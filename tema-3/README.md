# IOCLA - Tema 3

de Alexandru Sima (312CA)

--------------------------------------------------------------------------------

## Task 1

- Funcția inversează pozițiile vocalelor dintr-un string, fără a folosi
instrucțiuni precum `mov` sau `lea`.
- Pentru a se incărca un registru cu o valoare, se dă `push` la o valoare, apoi
`pop` în registrul respectiv.

### Implementare

- Se parcurge stringul până la `'\0'`, și se trimit vocalele pe stivă.
  - Pentru a verifica dacă un caracter e o vocală, am folosit instrucțiunea
  `repne scasb`, care verifică de maximum `ecx` ori dacă `al` == `[edi]`, apoi
  incrementează `edi`. Practic, funcționează similar cu `strchr`, doar că se
  oprește după caracterul găsit, de aceea stringul de vocale cu care se face
  comparația este 'aeiou*u*', pentru că, dacă litera era 'u', căutarea s-ar fi
  oprit la final și s-ar fi considerat că nu a fost găsit.
- Se parcurge din nou stringul și unde se găsește o vocală se înlocuiește cu cea
de pe stivă, obținându-se vocalele în ordine inversă.

--------------------------------------------------------------------------------

## Task 2

- Funcția concatenează directoarele date într-un vector de stringuri.

### Implementare

- Se parcurge vectorul de stringuri de `n` ori și se adaugă stringul pe stivă,
cu 2 excepții:
  - Dacă stringul este ".", nu se adaugă.
  - Dacă stringul este "..", nu se adaugă și se scoate ultimul string adăugat
  (dacă există).
- Verificarea s-a realizat cu ajutorul funcției `strcmp`.
- La final, se parcurge stiva de la bază la vârf și se concatenează stringurile,
iar după fiecare adăugare se adaugă și "/".

--------------------------------------------------------------------------------

## Task 3

- Funcția `get_words`, apelează iterativ funcția `strtok` pentru a sparge
stringul dat în cuvinte (întai strtok primește stringul, apoi NULL).

- Funcția `sort` apelează `qsort` pentru a sorta vectorul de stringuri, folosind
funcția `compare` pentru a compara stringurile.

- Funcția `compare` compară întâi lungimile stringurilor.
  - Dacă sunt diferite, returnează diferența lor.
  - Dacă sunt egale, se compară lexicografic, folosind funcția `strcmp` și se
  întoarce rezultatul comparației.
  - Astfel, funcția întoarce un număr negativ dacă primul string este "mai mic"
  decât al 2-lea, 0 dacă sunt egale și un număr pozitiv în rest, fiind astfel
  compatibilă cu qsort.

--------------------------------------------------------------------------------

## Task 4

- Funcția `inorder_parc` parcurge arborele în preordine, apelând recursiv
funcția, întâi pentru fiul din stânga, după aceea stocând nodul curent, iar apoi
pentru fiul din dreapta, oprindu-se când nodul curent este `NULL`.

- Funcția `inorder_intruders` parcurge arborele în preordine până la frunze,
apoi compară nodul la care s-a ajuns cu fiii săi, verificând dacă fiul din
stânga este mai mare decât nodul curent sau dacă fiul din dreapta este mai mic
decât nodul curent. Dacă da, se adaugă nodul în vectorul de noduri.

- Funcția `inorder_fixing` parcurge recursiv arborele în preordine până ajunge
la frunze, apoi compară nodul la care s-a ajuns cu fiii săi, modificându-i fiii
pentru a respecta proprietatea arborelui.

--------------------------------------------------------------------------------

## Bonus 1

- Programul este compilat pe 64 de biți, deci parametrii nu sunt trimiși pe
stivă, ci în anumiți regiștrii.
- Funcția intercalează 2 vectori cu lungimi variabile.

### Implementare

- Se parcurg vectorii și se adaugă elementele în vectorul rezultat, până când
unul dintre vectori a fost golit.
- Se insereză elementele rămase din primul vector, apoi din al doilea (unul
dintre ei fiind gol, se inserează doar elementele din cel rămas).
  - Pentru inserări am folosit instrucțiunea `rep movsd`, care copiază `rcx`
  dword-uri de la `rsi` la `rdi`.

--------------------------------------------------------------------------------

## Bonus 2

- Programul folosește sintaxa AT&T.
- Funcția adună 2 vectori element cu element, apoi scade 3 valori din rezultat.
Pentru a nu repeta cod, cele 3 scăderi se fac cu ajutorul unui macro.
- Macroul `sub_values` calculează poziția la care se face scăderea (scalând, cu
ajutorul regulii de 3 simple, poziția dintr-un vector de lungime 10, definită în
constantele `%_POSITION`), apoi scăzând la acea poziție valoarea `%_VALUE`.

--------------------------------------------------------------------------------

## Bonus 3

- Funcția înlocuiește toate aparițiile cuvântului 'Marco' cu 'Polo', folosind
apeluri de sistem pentru operațiile cu fișiere.

### Implementare

- Se alocă pe stivă un buffer.
- Se deschid fișierele de intrare și ieșire.
- Dacă a intervenit o eroare (remarcată printr-un file descriptor negativ), se
termină execuția programului și se întoarce eroarea.
- Se citește din fișierul de intrare în buffer, apoi se caută cuvântul 'Marco'.
  - Dacă se găsește, se scrie în fișierul de ieșire tot ce era în buffer până la
  cuvântul 'Marco', apoi se scrie 'Polo'.
  - Dacă nu se găsește, se scrie tot bufferul în fișierul de ieșire.
  - Se repetă până când se ajunge la sfârșitul fișierului de intrare.
- Se închid fișierele și se termină execuția programului.

--------------------------------------------------------------------------------

## Bonus 4

- Funcția calculează `s * A + B .* C`; A, B, C - vectori; s - scalar.
- Am folosit instrucțiuni SSE, ca să nu le folosesc pe cele pe care le-ați lăsat
în schelet😇.

## Implementare

- Se încarcă în `xmm0` valoarea scalarului `s` și se umple vectorul cu această
valoare.

- Se încarcă în `xmm1` 4 elemente din `A` și se calculează `s * A`.
- Se încarcă în `xmm2` 4 elemente din `B` și 4 din `C` în `xmm3` și se
calculează `B .* C`.

- Se adună cei 2 produși și se stochează în `D`.
- Se trece la următoarele 4 elemente etc.

--------------------------------------------------------------------------------

## Bonus 5

- Funcția calculează `x * sqrt(2) + y * sin(z* PI * 1/e)`.

### Implementare

- Calcularea lui `1/e` s-a realizat cu o serie Taylor cu 11 termeni
( `sum ((-1)^n / n!)` )
- Pentru că operațiile cu float-uri se fac folosindu-se o stivă, acestea se fac
cel mai ușor folosind forma poloneză postfixată (am schimbat ordinea
operațiilor, pentru că adunarea și înmulțirea sunt comutative):
`(1/e) pi * z * sin y * 2 sqrt x * +`

--------------------------------------------------------------------------------

## Bonus 6

- Funcția `get_rand` folosește instrucțiunea `rseed` pentru a genera un număr
aleatoriu. Pentru a se verifica că numărul nu este văzut de `gdb`, se
cronometrează măsoară numărul de cicli de procesor, iar dacă e mai mare decât o
anumită valoare, se consideră că funcția nu e sigură și se întoarce 0.

- Programul `iocla_rezolvari_examen_gratis_no_clickbait` conține leakuri cu
subiectele care vor fi anul acesta la examen, explicate și rezolvate de indieni
pe Youtube, iar la rulare îți oferă unul dintre linkuri, selectat cu ajutorul
funcției `get_rand`. Ca să nu le găsească echipa de IOCLA folosind `strings`🤓,
acestea au fost criptate.
  - Algoritmul de criptare este următorul (sursă de inspirație: CTF-ul de
  duminică):
    - Se alege un seed relativ la întâmplare (lungimea secțiunii `.text` a
    programului).
    - Se generează un număr aleator cu seedul acela.
    - Se face XOR între acel număr și caracterul curent din stringul de criptat.
    - Numărul obținut e caracterul criptat.
    - Numărul aleatoriu este folosit ca seed pentru criptarea următorului
    caracter și tot așa.
