#RUN THIS COMMANDS BEFORE START SCRIPT
#pip install openpyxl
#pip install pyarrow
#pip install GitPython pandas

import git
import pandas as pd

# Путь к локальному репозиторию GitLab
repo_path = '<your_path>'

# Инициализация Git-репозитория
repo = git.Repo(repo_path)

# Получение списка всех коммитов
commits = list(repo.iter_commits())

# Создание DataFrame с использованием конструктора
commit_data = pd.DataFrame([
    {
        'Когда': pd.to_datetime(commit.authored_datetime),
        'Кто': commit.author.name,
        'Название': commit.summary,
        'Описание': commit.message
    }
    for commit in commits
])

# Преобразование столбца 'Когда' в объект без часового пояса
commit_data['Когда'] = commit_data['Когда'].apply(lambda x: x.replace(tzinfo=None))

# Сохранение данных в Excel
commit_data.to_excel('commits.xlsx', index=False)
