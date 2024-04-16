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
- <link> – ссылка для подключения iOS Chat SDK (предоставляется компанией NAUMEN)
- <version> – номер версии iOS Chat SDK

3. Выполнить команду `pod install --repo-update` в директории проекта

### Swift Package Manager (доступен с версии 23.7.0, минимальная версия iOS: 12.0)
Xcode имеет встроенный менеджер зависимостей Swift Package Manager. Вы можете добавить пакет, выбрав `File -> Add Packages Dependencies...` и вставив в строку поиска ссылку на репозиторий iOS Chat SDK. Подробнее читайте в [документации Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).
Или вы можете добавить следующую зависимость в файл Package.swift:
```swift
dependencies: [
    .package(url: "<link>", .upToNextMajor(from: "<version>"))
]
```
Где:
- <link> – ссылка для подключения iOS Chat SDK (предоставляется компанией NAUMEN)
- <version> – номер версии iOS Chat SDK

### Общее
Необходимо заполнить пустые параметры в методе `configureChatSDK()` в файле [AppDelegate.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/AppDelegate.swift)

## На что обратить внимание при интеграции
- В файле [ViewController.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/ViewController.swift) можно увидеть пример встраивания SDK через кастомный контроллер [ChatContainer](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/ChatContainer.swift). Важно отметить, что контроллер-контейнер для контроллера чата должен соответствовать протоколу `NChatSDKToolbar` и включать NavigationBar
- В качестве примера в проекте присутствует кастомный контейней для контроллера чата [ChatContainer](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/ChatContainer.swift), в котором используюется кастомный TitleView [ImageTitleView.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/ImageTitleView.swift) и кнопку с аватаром оператора [AvatarButton.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/AvatarButton.swift)
- Стоит обратить внимание на настройку кастомизации в методе `getTheme()` файла  [AppDelegate.swift](https://github.com/nauphone/iOS-Chat-SDK-Integration-Example/blob/master/iOS%20Chat%20SDK%20Integration%20Example/AppDelegate.swift). Кастомизацию можно провести как изменением значений параметров, так и используя конструкторы.

## Важно
- В данном примере показан пример встраивания с использованием собственного контейнера. Дополнительную информацию можно получить в [документации](https://callcenter.naumen.ru/docs/ru/ncc76/ncc/web/ncc.htm#Integration/MobileSDK_Chat/MobileSDK_iOS/MobileSDK_IOS.htm%3FTocPath%3D%25D0%2598%25D0%25BD%25D1%2582%25D0%25B5%25D0%25B3%25D1%2580%25D0%25B0%25D1%2586%25D0%25B8%25D0%25BE%25D0%25BD%25D0%25BD%25D1%258B%25D0%25B5%2520%25D0%25B2%25D0%25BE%25D0%25B7%25D0%25BC%25D0%25BE%25D0%25B6%25D0%25BD%25D0%25BE%25D1%2581%25D1%2582%25D0%25B8%7CSDK%2520%25D0%25B4%25D0%25BB%25D1%258F%2520%25D0%25B8%25D0%25BD%25D1%2582%25D0%25B5%25D0%25B3%25D1%2580%25D0%25B0%25D1%2586%25D0%25B8%25D0%25B8%2520NCC-%25D1%2587%25D0%25B0%25D1%2582%25D0%25B0%2520%25D0%25B2%2520%25D0%25BC%25D0%25BE%25D0%25B1%25D0%25B8%25D0%25BB%25D1%258C%25D0%25BD%25D1%258B%25D0%25B5%2520%25D0%25BF%25D1%2580%25D0%25B8%25D0%25BB%25D0%25BE%25D0%25B6%25D0%25B5%25D0%25BD%25D0%25B8%25D1%258F%7CNCC-%25D1%2587%25D0%25B0%25D1%2582%2520iOS%2520SDK%7C_____0)
- Интерфейс SDK можно широко кастомизировать. Ознакомиться с примерами кастомизации также можно в [документации](https://callcenter.naumen.ru/docs/ru/ncc76/ncc/web/ncc.htm#Integration/MobileSDK_Chat/MobileSDK_iOS/MobileSDK_IOS_View.htm%3FTocPath%3D%25D0%2598%25D0%25BD%25D1%2582%25D0%25B5%25D0%25B3%25D1%2580%25D0%25B0%25D1%2586%25D0%25B8%25D0%25BE%25D0%25BD%25D0%25BD%25D1%258B%25D0%25B5%2520%25D0%25B2%25D0%25BE%25D0%25B7%25D0%25BC%25D0%25BE%25D0%25B6%25D0%25BD%25D0%25BE%25D1%2581%25D1%2582%25D0%25B8%7CSDK%2520%25D0%25B4%25D0%25BB%25D1%258F%2520%25D0%25B8%25D0%25BD%25D1%2582%25D0%25B5%25D0%25B3%25D1%2580%25D0%25B0%25D1%2586%25D0%25B8%25D0%25B8%2520NCC-%25D1%2587%25D0%25B0%25D1%2582%25D0%25B0%2520%25D0%25B2%2520%25D0%25BC%25D0%25BE%25D0%25B1%25D0%25B8%25D0%25BB%25D1%258C%25D0%25BD%25D1%258B%25D0%25B5%2520%25D0%25BF%25D1%2580%25D0%25B8%25D0%25BB%25D0%25BE%25D0%25B6%25D0%25B5%25D0%25BD%25D0%25B8%25D1%258F%7CNCC-%25D1%2587%25D0%25B0%25D1%2582%2520iOS%2520SDK%7C%25D0%259D%25D0%25B0%25D1%2581%25D1%2582%25D1%2580%25D0%25BE%25D0%25B9%25D0%25BA%25D0%25B0%2520%25D0%25B2%25D0%25BD%25D0%25B5%25D1%2588%25D0%25BD%25D0%25B5%25D0%25B3%25D0%25BE%2520%25D0%25B2%25D0%25B8%25D0%25B4%25D0%25B0%2520NCC-%25D1%2587%25D0%25B0%25D1%2582%25D0%25B0%7C_____0)
