# Пример встраивания NAUMEN iOS Chat SDK 

<p align="center">
<img src="https://i.ibb.co/KLyLXq1/IMG-5835.png" alt="drawing" width="340"/>
</p>

## Первичная настройка
В зависимости от выбранного способа интеграции, провести следующие действия:
### CocoaPods
1. Необходимо инициализировать CocoaPods в проекте путем выполнения команды `pod init`
2. Необходимо добавить в `Podfile` следующие строки:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/nauphone/chatpods.git'

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
    config.build_settings['ENABLE_BITCODE'] = 'NO'
  end
end

pod 'ChatSDK', :git => '<link>', :tag => '<version>'
```
Где:
- link – ссылка для подключения iOS Chat SDK (предоставляется компанией NAUMEN)
- version – номер версии iOS Chat SDK

3. Выполнить команду `pod install --repo-update` в директории проекта

### Swift Package Manager (доступен с версии 23.7.0)
Xcode имеет встроенный менеджер зависимостей Swift Package Manager. Вы можете добавить пакет, выбрав `File -> Add Packages Dependencies...` и вставив в строку поиска ссылку на репозиторий iOS Chat SDK. Подробнее читайте в [документации Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).
Или вы можете добавить следующую зависимость в файл Package.swift:
```swift
dependencies: [
    .package(url: "<link>", .upToNextMajor(from: "<version>"))
]
```
Где:
- link – ссылка для подключения iOS Chat SDK (предоставляется компанией NAUMEN)
- version – номер версии iOS Chat SDK

## Настройка и инициализация Chat SDK
1. Необходимо выбрать способ передачи данных авторизации пользователя
2. Необходимо заполнить пустые параметры `NChatSDKService` в методе `configureChatSDK()` в файле [AppDelegate.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/23.12.0/iOS%20Chat%20SDK%20Integration%20Example/AppDelegate.swift)

### Выбор способа передачи данных авторизации пользователя
Существует три варианта создания данных авторизации ([документация](https://callcenter.naumen.ru/docs/ru/ncc/web/Content/Integration/MobileSDK_Chat/MobileSDK_iOS/MobileSDK_IOS_NChatSDKAuthData.htm)):
- Первый вариант. Авторизация с использованием crmId:
```swift
let authData = NChatSDKAuthData(
    crmId: deviceID, // Уникальный идентификатор пользователя
    attributes: attributes // Произвольные параметры
)
```

- Второй вариант. Авторизация с использованием генерируемого на стороне SDK JWT-токена (рекомендуемый вариант):
```swift
let authData = NChatSDKAuthData(
    crmId: deviceID, // Уникальный идентификатор пользователя
    attributes: attributes, // Произвольные параметры
    privateKey: "<Приватный ключ>" // Приватный ключ для генерации JWT-токена. Документация: https://callcenter.naumen.ru/docs/ru/ncc/web/Content/WebChat/Token_Use.htm
)
```
**Примечание:** Используется шифрование RS256. Токен генерируется локально

- Третий вариант. Авторизация с использованием JWT-токена (рекомендуемый вариант):
```swift
let authData = NChatSDKAuthData(
    token: "<JWT-токен>", // Токен необходимо сгенерировать заранее. Документация: https://callcenter.naumen.ru/docs/ru/ncc/web/Content/WebChat/Token_Use.htm
    attributes: attributes // Произвольные параметры
)
```
**Примечание:** Данные переданные в JWT-токене являются приоритетными

В зависимости от версии настройка и инициализация Chat SDK могут отличаться:
- [Пример интеграции Chat SDK в версии 23.12.0](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/tree/23.12.0)
- [Пример интеграции Chat SDK 24.0.0 и выше](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/tree/24.0.0)

### Инициализация SDK
Необходимо заполнить данные инициализатора `NChatSDKService` в зависимости от интеграции NCC Chat и настроек витрины чата:
```swift
let chatSDKService = NChatSDKService(
    authData: authData, // Данные авторизации пользователя
    showcaseId: , // Идентификатор витрины
    url: , // Адрес сервера ("https://" + <api host>)
    wsUrl: , // Адрес websocket ("wss://" + <websocket host>)
    theme: getTheme(), // Тема для чата
    handler: Handler() // Обработчик событий
)
```

## На что обратить внимание при интеграции
- В файле [ViewController.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/24.0.0/iOS%20Chat%20SDK%20Integration%20Example/ViewController.swift) можно увидеть пример встраивания SDK через кастомный контроллер [ChatContainer](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/24.0.0/iOS%20Chat%20SDK%20Integration%20Example/ChatContainer.swift). Важно отметить, что контроллер-контейнер для контроллера чата должен соответствовать протоколу `NChatSDKToolbar` и включать NavigationBar
- В качестве примера в проекте присутствует кастомный контейней для контроллера чата [ChatContainer](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/24.0.0/iOS%20Chat%20SDK%20Integration%20Example/ChatContainer.swift), в котором используюется кастомный TitleView [ImageTitleView.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/24.0.0/iOS%20Chat%20SDK%20Integration%20Example/ImageTitleView.swift) и кнопку с аватаром оператора [AvatarButton.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/24.0.0/iOS%20Chat%20SDK%20Integration%20Example/AvatarButton.swift)
- Стоит обратить внимание на настройку кастомизации в методе `getTheme()` файла  [AppDelegate.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/24.0.0/iOS%20Chat%20SDK%20Integration%20Example/AppDelegate.swift). Кастомизацию можно провести как изменением значений параметров, так и используя конструкторы.

## Важно
- В данном примере показан пример встраивания с использованием собственного контейнера. Дополнительную информацию можно получить в [документации](https://callcenter.naumen.ru/docs/ru/ncc/web/Content/Integration/MobileSDK_Chat/MobileSDK_iOS/MobileSDK_IOS.htm))
- Интерфейс SDK можно широко кастомизировать. Ознакомиться с примерами кастомизации также можно в [документации](https://callcenter.naumen.ru/docs/ru/ncc/web/Content/Integration/MobileSDK_Chat/MobileSDK_iOS/MobileSDK_IOS_View.htm)
