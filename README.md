# Кейс-задание по "Интерфейсам вычислительных систем"

## Задача
Реализовать протокол обмена на основе UART.

## Реализация
Кодер и декодер построены по расширенному коду Хэмминга,
который позволяет обнаруживать n-кратные ошибки и исправлять одиночные.

Кодер и передатчик написаны на Verilog, то есть на ПЛИС формируются
данные, которые запаковываются и отправляются на компьютер через RS-232.

Приёмник и декодер написаны на C с использованием библиотеки Windows.h
для работы с ядром Windows, чтобы принимать данные из виртуального COM-порта.

## Порядок работы

Сначала компилируется программа на Verilog в Quartus, программируется 
ПЛИС, затем уже идёт C.

В Hamming_transmitter лежит проект Quartus:

- В Data_memory инициализируются данные, которые лежат в Data.txt и которые
будут отправлены компьютеру.

- Transmitter представляет собой конечный автомат, который и отправляет пакет

- Coder_RS_232 запаковывает данные в пакеты по коду Хэмминга

- RS_232 представляет собой оболочку, который объединяет все модули и
регулирует их работу.

## Что сделать в будущем

1. Отполировать коды на Verilog и C;
2. Добавить возможность исправления одиночных ошибок;
3. На GitHub как можно полно описать работу с кодом Хэмминга,
с RS-232 (и в целом с UART) и с ядром Windows;
4. Реализовать полноценный полнодуплексный режим;
5. Попробовать организовать приём данных на Linux с помощью
OrangePi (подключение к GPIO);
6. Освоить QSerialPort на Qt.
 
