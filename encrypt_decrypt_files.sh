#!/bin/bash

show_help() {
    echo "Usage: lkk-crypt [options]"
    echo
    echo "Options:"
    echo " -h, --help           Показать справку"
    echo " -e, --encrypt        Зашифровать файл"
    echo " -d, --decrypt        Дешифровать файл"
    echo " -f, --file FILE      Указывает на путь к файлу"
    echo " --non-interactive    Запуск в неинтерактивном режиме"
}

handle_error() {
    echo "Ошибка: $1" >&2
    exit 1
}

encrypt_file() {
    local file_path=$1
    local password=$2

    openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in "$file_path" -out "$file_path.crypt" -k "$password"

    if [[ $? -eq 0 ]]; then
        echo "Файл успешно зашифрован"
        echo "Расположение файла:" $file_path.crypt
        rm -f $file_path
    else
        handle_error "An error occurred during encryption."
    fi
}

decrypt_file() {
    local file_path=$1
    local password=$2

    openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -d -salt -in "$file_path" -out "${file_path%.crypt}" -k "$password"

    if [[ $? -eq 0 ]]; then
        echo "Файл успешно дешифрован"
        rm -f $file_path
        echo "Расположение файла:" ${file_path%.crypt}
    else
        handle_error "An error occurred during decryption."
    fi
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

interactive=true
file_path=""
action=""
password=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--encrypt)
            action="encrypt"
            ;;
        -d|--decrypt)
            action="decrypt"
            ;;
        -f|--file)
            shift
            file_path=$1
            ;;
        --non-interactive)
            interactive=false
            ;;
        *)
            echo "Неизвестный параметр: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

if [[ $interactive == true ]]; then
    echo "Выберите действие:"
    echo "1. Зашифровать файл"
    echo "2. Дешифровать файл"
    read -p "Ваш выбор: " action_choice

    if [[ $action_choice -ne 1 && $action_choice -ne 2 ]]; then
        handle_error "Неверный выбор"
    fi

    read -e -p "Введите путь до файла: " file_path

    if [[ ! -f "$file_path" ]]; then
        handle_error "Файл по указанному пути не существует"
    fi

    read -p "Введите пароль: " password

    if [[ $action_choice -eq 1 ]]; then
        encrypt_file "$file_path" "$password"
    elif [[ $action_choice -eq 2 ]]; then
        decrypt_file "$file_path" "$password"
    fi
else
    if [[ -z "$file_path" || -z "$action" ]]; then
        echo "В неинтерактивном режиме необходимо указать файл и действие (--encrypt или --decrypt)"
        show_help
        exit 1
    fi

    read -p "Введите пароль: " password

    if [[ ! -f "$file_path" ]]; then
        handle_error "Файл по указанному пути не существует"
    fi

    if [[ $action == "encrypt" ]]; then
        encrypt_file "$file_path" "$password"
    elif [[ $action == "decrypt" ]]; then
        decrypt_file "$file_path" "$password"
    fi
fi
