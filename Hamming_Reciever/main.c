#include <windows.h> // Подключение библиотеки для работы с Win32API (позволяет работать с внешними устройствами)
#include <stdio.h>

#define NUM_OF_PACKAGE 6 // Количество пакетов

#define NUM_OF_BYTES NUM_OF_PACKAGE * 2 // Количество байтов

void RS_232_Get (unsigned char *buffer) // Функция получения данных из COM-порта
{
    HANDLE hComm; // Создание структуры "создания/открытия" файла

    DWORD bytesRead = 0; // Количество прочитанных байтов (не просто int, а специальный тип данных)

    // Открываем файл с именем COM? на чтение
    hComm = CreateFile(L"COM9", GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, NULL);

    DCB dcbSerialParams = {0}; // Создаём переменную для настройки COM-порта
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    int status = GetCommState(hComm, &dcbSerialParams); // Достаём из ядра текущее состояние интерфейса

    // Настраиваем COM-порт
    dcbSerialParams.BaudRate = 9600; // Скорость передачи данных
    dcbSerialParams.ByteSize = 8;    // Размер кадра
    dcbSerialParams.Parity = NOPARITY; // Бит чётности
    dcbSerialParams.StopBits = ONESTOPBIT; // Количество стоповых битов

    // Проверка настроенных параметров
    printf("BaudRate = %lu, ByteSize = %d, Parity = %d \n", dcbSerialParams.BaudRate, dcbSerialParams.ByteSize, dcbSerialParams.Parity);

    SetCommState(hComm, &dcbSerialParams); // Сообщаем настройки ядру

    if (hComm == INVALID_HANDLE_VALUE)
        printf("Error opening serial port!"); // Проверяем, открылся ли последовательный порт

    ReadFile(hComm, buffer, NUM_OF_BYTES, &bytesRead, NULL); // Читаем все данные (для этого мы указали их количество)

    CloseHandle(hComm); // Закрываем устройство (дескриптор)
}

int main()
{
    unsigned char frames[NUM_OF_BYTES]; // Массив кадров

    RS_232_Get(frames); // Принимаем пакеты

    int count_pac = 0; // Счётчик пакетов (служебная переменная)
    int bits[16];     // Вектор битов (чтобы отдельно с ними работать)

    unsigned char data; // Распакованные данные (то есть информационная часть)

    int parity_0, parity_1, parity_2, parity_4, parity_8; // Биты чётности для проверки

    for (int i = 0; i < NUM_OF_BYTES; i++) // Цикл обработки каждого пакета
    {
        if (i & 1) // Так как принимаем по кадру, ждём, когда второй придёт, чтобы разбирать весь пакет
        {
            count_pac++; // Приняли пакет

            // Сбрасываем
            parity_0 = 0;
            parity_1 = 0;
            parity_2 = 0;
            parity_4 = 0;
            parity_8 = 0;

            // Выводим пакет 16-м виде и далее разбираем его
            printf("Accepted package #%d: %02X%02X \n", count_pac, frames[i-1], frames[i]);

            /* Когда у нас есть число, мы не можем работать отдельно с его битами, поэтому
             * просто используем логические операции, чтобы получить двоичное представление.
             * Используется операция "И" и сдвиг влево. */

            for (int j = 0; j < 16; j++) // Цикл преобразования единого числа в последовательность битов
            {
                if ( 15 - j > 7 )
                    bits[15 - j] = (frames[i-1] & (1 << (7 - j))) ? 1:0;
                else
                    bits[15 - j] = (frames[i] & (1 << (15 - j))) ? 1:0;
            }

            // Проверка битов чётности (по таблице расширенного кода Хемминга)
            for (int j = 1; j < 16; j++)
                parity_0 ^=  bits[j];

            if (parity_0 != bits[0])
            {
                printf("Parity bit #0 not valid \n");
            }

            for (int j = 3; j < 16; j += 2)
                parity_1 ^=  bits[j];

            if (parity_1!= bits[1])
            {
                printf("Parity bit #1 not valid \n");
            }

            for (int j = 3; j < 16; j += 4)
                parity_2 ^=  bits[j];
            for (int j = 6; j < 16; j += 4)
                parity_2 ^=  bits[j];

            if (parity_2!= bits[2])
            {
                printf("Parity bit #2 not valid \n");
            }

            for (int j = 5; j < 8; j++)
                parity_4 ^=  bits[j];
            for (int j = 12; j < 16; j++)
                parity_4 ^=  bits[j];

            if (parity_4!= bits[4])
            {
                printf("Parity bit #4 not valid \n");
            }

            for (int j = 9; j < 16; j++)
                parity_8 ^=  bits[j];

            if (parity_8!= bits[8])
            {
                printf("Parity bit #8 not valid \n");
            }


            // Получение распакованных данных (правильных или неправильных)
            data = (bits[12] << 7) ^ (bits[11] << 6) ^ (bits[10] << 5) ^ (bits[9] << 4) ^ (bits[7] << 3)\
                   ^ (bits[6] << 2) ^ (bits[5] << 1) ^ bits[3];
            printf("Data: %02X \n", data);

        }

    }

    return 0;

}
