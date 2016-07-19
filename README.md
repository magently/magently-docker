# Magently Docker

## Opis

Środowisko do pracy oparte o [Dockera](https://docker.com) przygotowane do pracy z projektami wykorzystującymi [Grunta](http://gruntjs.com/).

## Wymagania

Do uruchomienia środowiska niezbędna jest wyłącznie instalacja [Dockera](https://docs.docker.com/engine/installation/) 1.11+ wraz z rozszerzeniem [Docker-compose](https://docs.docker.com/compose/install) 1.7+. Alternatywnie zamiast Dockera można zainstalować [Vagranta](https://www.vagrantup.com/docs/installation/).

## Instalacja

1. Pobierz archiwum ZIP i rozpakuj je w głównym katalogu projektu
2. Zaaktualizuj konfiguracje projektu:
...Baza danych:
...- host: db
...- port: 3306
...- user: root
...- pass: secret
3. Utwórz plik .env na bazie pliku .env.example
4. Nadaj odpowiednie uprawnienia plików:
...`$ find <ścieżka-do-projektu> -type f -exec chmod 664 {} \;`
...`$ find <ścieżka-do-projektu> -type d -exec chmod 775,g+s {} \;`
     
## Uruchomienie Dockera (zalecane)

Aby uruchomić środowisko wystarczy uruchomić polecenie:
`$ docker-composer up`

Po poprawnym uruchomienie aplikacja dostępna jest pod adresem http://localhost lub http://localhost:<EXTERNAL_HTTP_PORT> gdy EXTERNAL_HTTP_PORT w pliku .env jest inny niż 80.

## Uruchomienie Vagranta (niezalecane)

Aby uruchomić środowisko w wirtualnej maszynie Vagrant należy uruchomić polecenie:
`$ vagrant up`

Po poprawnym uruchomieniu aplikacja dostępna jest pod adresem http://localhost:8080. W pliku .env konieczne jest by zmienna środowiskowa EXTERNAL_HTTP_PORT przyjmowała wartość 80.

Wszystkie polecenia związane z Dockerem należy wywoływać z poziomu maszyny wirtualnej Vagrant.

## Uruchamianie poleceń w środowisku

Docker posiada wszystkie niezbędne narzędzia do pracy z aplikacją, oraz poprawną konfigurację środowiska. Wszelkie polecenia i skrypty dotyczące aplikacji należy uruchamiać przy pomocy dockera.

Aby uruchomić dowolną komendę a kontenerze aplikacji należy wykonać polecenie:
`$ docker-compose run --rm app <polecenie>`

Przykładowo, aby zainstalować dodatkowy pakiet za pomocą composera należy to zrobić w następujący sposób:
`$ docker-compose run --rm app composer require <nazwa-pakietu>`

## Połączenie z bazą danych

W celu połączenia się z bazą danych należy uruchomić środowisko, a następnie wywołać polecenie:
`$ docker-compose exec db mysql -psecret`
