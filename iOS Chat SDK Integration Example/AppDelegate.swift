//
//  AppDelegate.swift
//  iOS Chat SDK Integration Example
//
//  Created by Ilya Sokolov on 25.11.2022.
//

import UIKit
import ChatSDK
import MobileCoreServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var chatSDKService: NChatSDKService?
    
    var authData: NChatSDKAuthData? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Добавление собственных типов отправляемых файлов
        // Список всех типов https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
        AttachTypes.addNewTypes([kUTTypePDF])
        
        // Установка возможности использования голосовых сообщейний
        Settings.shared.voiceIsOn = true
        
        // Настройки поведения отправки и отображения голосового сообщения
        VoiceMessageSettings.shared.setupSettings(
            sendMessageAfterReleasing: true,
            sendMessageAfterStopButtonTap: true,
            showVoiceMessagePreviewInChat: false
        )
        
        // Настройка таймаутов

        // Настройка таймаутов для запросов
        TimeoutSettings.shared.request = TimeoutSettings.Request(
            getTimeout: 60,
            postTimeout: 60,
            downloadTimeout: 60,
            uploadTimeout: 60
        )

        // Настройка таймаутов для видеозвонка
        TimeoutSettings.shared.videoCall = TimeoutSettings.VideoCall(
            callConnectionTimeout: 30,
            networkConnectionTimeout: 5
        )

        // Настройка таймаутов для вебсокет-соединения
        TimeoutSettings.shared.webSocket = TimeoutSettings.WebSocket(
            connectionTimeout: 5,
            pingInterval: 60
        )
        
        // Установка расположения положения лейбла "Оператор печатает" Сверху(в NavigationBar) / Снизу(Над строкой ввода сообщения)
        OperatorTypingLabelLocationSettings.shared.setLocation(.bottom)
        
        // Установка расположения времени и статуса, имени оператора в/вне облака сообщения
        MessageBubbleSettings.shared.setupSettings(
            timeAndStatusInBubble: false,
            operatorNameInBubble: false
        )
        
        // Установка отображения затемнения при вызове меню вложений
        PopupBlackoutSettings.shared.setupSettings(true)

        // Настройка кеширования сообщений
        NCacheSettings.shared.setupSettings(
            shouldCacheMessages: true,
            shouldHideFilesFolder: true
        )

        // Настройка списка вложений. Для установки стандартного списка вложений настройку призводить не нужно
//        AttachMenuList.shared.setList([
//            AttachMenuModel(name: "Фото с камеры", image: StandardImages.addPhoto, type: .cameraPhoto),
//            AttachMenuModel(name: "Видео с камеры", image: StandardImages.addVideo, type: .cameraVideo),
//            AttachMenuModel(name: "Галерея", image: StandardImages.photo, type: .galery),
//            AttachMenuModel(name: "Документ", image: StandardImages.document, type: .file),
//            AttachMenuModel(name: "Местоположение", image: StandardImages.location, type: .location)
//        ])
        
        // Установка кастомного файла локализации
//        NChatSDKLocalization.setLocalizationTable("<название файла локализации>")
        
        configureChatSDK()
        
        return true
    }
    
    class Handler: NChatSDKEventHandler {

        @objc func onNewMessage(_ newMessage: NChatSDKMessage) {}

        @objc func onDialogResolved(_ conversationId: Int64) {}

        @objc func onRate() {}

        @objc func onNewDialog(_ newDialog: NChatSDKConversation) {}

    }
    
    private func configureChatSDK() {
        // Инициализация SDK
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

        // Произвольные параметры для передачи в SDK
        var attributes: [String: String] = [:]

        // Передача токена для push-уведомлений
        attributes.updateValue("<токен для push-уведомлений>", forKey: "APP_PUSH_ID")

        // Передача данных авторизации (три варианта):
        // Документация: <Ссылка на документацию>
        // Первый вариант: авторизация через crmId
        let authData = NChatSDKAuthData(
            crmId: deviceID, // Уникальный идентификатор пользователя
            attributes: attributes // Произвольные параметры
        )

        // Второй вариант: авторизация с использованием генерируемого на стороне SDK JWT-токена (используется шифрование RS256)
        // Рекомендуется к использованию
        let authData = NChatSDKAuthData(
            crmId: deviceID, // Уникальный идентификатор пользователя
            attributes: attributes, // Произвольные параметры
            privateKey: "<Приватный ключ>" // Приватный ключ для генерации JWT-токена. Документация: https://callcenter.naumen.ru/docs/ru/ncc/web/Content/WebChat/Token_Use.htm
        )

        // Третий вариант: авторизация с использованием JWT-токена
        // Рекомендуется к использованию
        let authData = NChatSDKAuthData(
            token: "<JWT-токен>", // Токен необходимо сгенерировать заранее. Документация: https://callcenter.naumen.ru/docs/ru/ncc/web/Content/WebChat/Token_Use.htm
            attributes: attributes // Произвольные параметры
        )

        // Инициализация NChatSDKService
        let chatSDKService = NChatSDKService(
            authData: authData, // Данные авторизации пользователя
            showcaseId: , // Идентификатор витрины
            url: , // Адрес сервера ("https://" + <api host>)
            wsUrl: , // Адрес websocket ("wss://" + <websocket host>)
            theme: getTheme(), // Тема для чата
            handler: Handler() // Обработчик событий
        )

        self.chatSDKService = chatSDKService
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Тема для чата
    
    func getTheme() -> ChatTheme {
        let chatTheme = ChatTheme()
        
        // Цвет фона для чата
        chatTheme.chatMessageBox.background = UIColor(netHex: 0xF5F6F8)
        
        // Изображение для фона чата (опционально)
//        chatTheme.chatMessageBox.backgroundImage = nil
        
        // Возможность просматривать отправленные файлы (при нажатии на изображение/файл)
        chatTheme.chatMessageBox.needShowDownloadedFiles = true
        
        // Отображение статуса "Оператор печатает..."
        chatTheme.chatMessageBox.needShowAgentTypingStatus = true
        
        // Длительность отображения ошибки
        chatTheme.chatMessageBox.errorDuration = 5.0
        
        // Тема для сообщения оператора
        chatTheme.chatMessageBox.operatorMessage = self.getOperatorMessageTheme()
        
        // Тема для сообщения пользователя
        chatTheme.chatMessageBox.userMessage = self.getUserMessageTheme()
        
        // Тема для подсказки
        chatTheme.chatMessageBox.tooltip = self.getTooltipTheme()

        // Тема для системного сообщения
        chatTheme.chatMessageBox.systemMessage = self.getSystemMessageTheme()
        
        // Тема для приветственного сообщения
        chatTheme.chatMessageBox.inlinePrechat = self.getInlinePrechatTheme()
        
        // Тема для пречат-полей
        chatTheme.chatMessageBox.prechat = self.getPrechatTheme()
        
        // Тема для панели ввода
        chatTheme.chatMessageBox.input = self.getInputPanelTheme()

        // Тема для панели превью цитирования сообщения
        chatTheme.chatMessageBox.replyMessageTheme = self.getReplyMessageTheme()

        // Тема для панели вложения
        chatTheme.chatMessageBox.attachment = self.getAttachmentPanelTheme()
        
        // Тема для кнопки начала нового диалога
        chatTheme.chatMessageBox.newDialog = self.getNewDialogTheme()
        
        // Тема для сообщения "Оператор печатает..."
        chatTheme.chatMessageBox.agentTypingStatus = self.getAgentTypingStatusTheme()

        // Тема для NavigationBar
        chatTheme.chatMessageBox.navigationBar = self.getNavigationBarTheme()
        
        // Тема для отправки истории диалога на почту
        chatTheme.chatMessageBox.sendHistory = self.getSendHistoryTheme()
        
        // Тема для видеозвонка
        chatTheme.chatMessageBox.videoCall = self.getVideoCallTheme()

        // Тема для окна оценки диалога
        chatTheme.chatMessageBox.ratingScreen = self.getRatingScreenTheme()
        
        // Тема для сообщения с оценкой диалога
        chatTheme.chatMessageBox.rateResponse = self.getRateResponseTheme()

        // Тема для панели автодополнений
        chatTheme.chatMessageBox.autocomplete = self.getAutocompleteTheme()
        
        // Тема для отображаемой ошибки (кроме экрана чата)
        chatTheme.chatMessageBox.error = self.getErrorTheme()
        
        // Тема для отображаемой ошибки на экране чата
        chatTheme.chatMessageBox.chatError = self.getChatErrorTheme()
        
        // Тема для разделителя с датой
        chatTheme.chatMessageBox.chatDate = self.getChatDateTheme()
        
        // Тема для контроллера выбора типа вложения
        chatTheme.chatMessageBox.popupControllerStyle = self.getAttachPopupControllerTheme()
        
        // Тема для сообщения о том, что витрина оффлайн
        chatTheme.chatMessageBox.offlineMessage = self.getOfflineMessageTheme()
        
        // Тема для сообщения о том, что витрина заблокирована
        chatTheme.chatMessageBox.showcaseBlockedPanel = self.getShowcaseBlockedPanelTheme()
        
        // Тема для опросника
        chatTheme.chatMessageBox.questionnaire = self.getQuestionaryTheme()
        
        // Тема для кнопки прокрутки истории диалога
        chatTheme.chatMessageBox.scrollDownArrow = self.getScrollDownArrowTheme()
        
        // Тема для контекстного меню
        chatTheme.chatMessageBox.contextMenu = self.getContextMenuTheme()
        
        return chatTheme
    }
    
    // MARK: - Тема для оператора
    
    func getOperatorMessageTheme() -> MessageTheme {
        let chatTheme = ChatTheme()
        
        // Настройка расположения области даты относительно баббла сообщения
        chatTheme.chatMessageBox.operatorMessage.outgoingDateViewAlignment = NSTextAlignment.right

        // Тема для настройки имени отправителя при цитировании
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.operatorColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.clientColor = UIColor.white
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.lineSpacing = 3

        // Тема для настройки текста при цитировании
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.operatorTextColor = UIColor.black.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.clientTextColor = UIColor.white.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.textFont = UIFont.systemFont(ofSize: 13)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.lineSpacing = 3
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.clientIconColor = UIColor.white.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.operatorIconColor = UIColor.black.withAlphaComponent(0.72)

        // Тема для текстового сообщения
        chatTheme.chatMessageBox.operatorMessage.text.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.text.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.text.dateColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.text.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.text.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.text.padding = Padding(left: 14, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.operatorMessage.text.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.text.incomingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.operatorMessage.text.messageStatusIndicator = getMessageStatusIndicatorTheme()

        // Тема для сообщения c файлом
        chatTheme.chatMessageBox.operatorMessage.file.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.file.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.file.dateColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.file.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.file.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.file.padding = Padding(left: 14, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.operatorMessage.file.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.file.incomingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.operatorMessage.file.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.operatorMessage.file.iconColor = UIColor(netHex: 0xE8E9EC)
        chatTheme.chatMessageBox.operatorMessage.file.icon = StandardImages.insertDriveFile
        chatTheme.chatMessageBox.operatorMessage.file.iconBackgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.file.fileNameColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.file.fileSizeColor = UIColor(netHex: 0x767676)
        
        // Тема для сообщения c изображением
        chatTheme.chatMessageBox.operatorMessage.image.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.image.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.image.dateColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.image.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.image.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.image.padding = Padding(left: 16, top: 10, right: 10, bottom: 10)
        chatTheme.chatMessageBox.operatorMessage.image.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.image.incomingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.operatorMessage.image.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.operatorMessage.image.imageCornerRadius = 10
        chatTheme.chatMessageBox.operatorMessage.image.previewStyle = ImageMessageTheme.PreviewStyle.crop
        chatTheme.chatMessageBox.operatorMessage.image.textPadding = Padding(left: 10, top: 10, right: 16, bottom: 10)
        
        // Тема для голосового сообщения
        // Общее
        chatTheme.chatMessageBox.operatorMessage.voice.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.voice.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.voice.dateColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.voice.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.voice.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.voice.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.voice.incomingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.operatorMessage.voice.messageStatusIndicator = getMessageStatusIndicatorTheme()

        // Тема для голосового сообщения в баббле
        chatTheme.chatMessageBox.operatorMessage.voice.message.bubbleImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.operatorMessage.voice.message.bubbleColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.message.playButton.icon = StandardImages.play
        chatTheme.chatMessageBox.operatorMessage.voice.message.playButton.iconColor = UIColor.white
        chatTheme.chatMessageBox.operatorMessage.voice.message.playButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        chatTheme.chatMessageBox.operatorMessage.voice.message.pauseButton.icon = StandardImages.pause
        chatTheme.chatMessageBox.operatorMessage.voice.message.pauseButton.iconColor = UIColor.white
        chatTheme.chatMessageBox.operatorMessage.voice.message.pauseButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        chatTheme.chatMessageBox.operatorMessage.voice.message.slider.cursorImage = StandardImages.thumb
        chatTheme.chatMessageBox.operatorMessage.voice.message.slider.cursorColor = UIColor.white
        chatTheme.chatMessageBox.operatorMessage.voice.message.slider.playBarColor = UIColor.gray.withAlphaComponent(0.2)
        chatTheme.chatMessageBox.operatorMessage.voice.message.slider.playedBarColor = UIColor.gray.withAlphaComponent(0.2)
        chatTheme.chatMessageBox.operatorMessage.voice.message.textSize = 14
        chatTheme.chatMessageBox.operatorMessage.voice.message.textFont = nil

        // Тема для превью голосового сообщения
        chatTheme.chatMessageBox.operatorMessage.voice.preview.playIcon = StandardImages.play
        chatTheme.chatMessageBox.operatorMessage.voice.preview.playIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.preview.pauseIcon = StandardImages.pause
        chatTheme.chatMessageBox.operatorMessage.voice.preview.pauseIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.preview.deleteIcon = StandardImages.delete
        chatTheme.chatMessageBox.operatorMessage.voice.preview.deleteIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.preview.slider.cursorImage = StandardImages.thumb
        chatTheme.chatMessageBox.operatorMessage.voice.preview.slider.cursorColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.preview.slider.playBarColor = UIColor.lightGray
        chatTheme.chatMessageBox.operatorMessage.voice.preview.slider.playedBarColor = UIColor.lightGray
        chatTheme.chatMessageBox.operatorMessage.voice.preview.textSize = 14
        chatTheme.chatMessageBox.operatorMessage.voice.preview.textFont = nil
        chatTheme.chatMessageBox.operatorMessage.voice.preview.textColor = UIColor.black

        // Тема для сообщения с кнопками
        chatTheme.chatMessageBox.operatorMessage.buttons.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.buttons.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.buttons.dateColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.buttons.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.buttons.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.buttons.padding = Padding(left: 14, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.operatorMessage.buttons.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.buttons.incomingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.operatorMessage.buttons.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.operatorMessage.buttons.maxButtonsCount = 5
        chatTheme.chatMessageBox.operatorMessage.buttons.spaceBetweenButtons = 4
        chatTheme.chatMessageBox.operatorMessage.buttons.buttonsInset = UIEdgeInsets(top: 10, left: 6, bottom: 6, right: 6)
        chatTheme.chatMessageBox.operatorMessage.buttons.isHorizontalArrangement = false

        // Тема для кнопки в сообщении с кнопками
        chatTheme.chatMessageBox.operatorMessage.buttons.button.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.operatorMessage.buttons.button.backgroundColorPressed = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.buttons.button.textColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.buttons.button.textColorPressed = UIColor.white
        chatTheme.chatMessageBox.operatorMessage.buttons.button.borderColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.buttons.button.borderColorPressed = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.buttons.button.borderRadius = 8
        chatTheme.chatMessageBox.operatorMessage.buttons.button.borderWidth = 1.5
        chatTheme.chatMessageBox.operatorMessage.buttons.button.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.buttons.button.textAlignment = NSTextAlignment.center
        chatTheme.chatMessageBox.operatorMessage.buttons.button.titleInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        // Тема для кнопки множественного выбора в сообщении с кнопками
        chatTheme.chatMessageBox.operatorMessage.buttons.selectorButton.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.buttons.selectorButton.tintColor = UIColor.gray
        chatTheme.chatMessageBox.operatorMessage.buttons.selectorButton.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.buttons.selectorButton.size = CGSize(width: 200, height: 30)

        // Тема для иконки оператора в сообщении
        // Аватара
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.size = CGSize(width: 36, height: 36)
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.cornerRadius = 18
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.topIndent = 5
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.leftIndent = 8
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.rightIndent = 8
        
        // Имя
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.name.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.name.textColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.name.leftIndent = 0
        
        // Тема для установки отступа сообщения от краев экрана
        chatTheme.chatMessageBox.operatorMessage.messageIndent = MessageIndentTheme(top: 0, leading: 0, trailing: 0, bottom: 0)

        return chatTheme.chatMessageBox.operatorMessage
    }
    
    // MARK: - Тема для пользователя
    
    func getUserMessageTheme() -> MessageTheme {
        let chatTheme = ChatTheme()
        
        // Настройка расположения области даты относительно баббла сообщения
        chatTheme.chatMessageBox.userMessage.outgoingDateViewAlignment = NSTextAlignment.right

        // Тема для настройки имени отправителя при цитировании
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.operatorColor = UIColor.black
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.clientColor = UIColor.white
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        chatTheme.chatMessageBox.operatorMessage.replySenderNameTheme.lineSpacing = 3

        // Тема для настройки текста при цитировании
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.operatorTextColor = UIColor.black.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.clientTextColor = UIColor.white.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.textFont = UIFont.systemFont(ofSize: 13)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.lineSpacing = 3
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.clientIconColor = UIColor.white.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.operatorMessage.replyMessageTheme.operatorIconColor = UIColor.black.withAlphaComponent(0.72)

        // Тема для текстового сообщения
        chatTheme.chatMessageBox.userMessage.text.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.text.textColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.text.dateColor = UIColor.black
        chatTheme.chatMessageBox.userMessage.text.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.text.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.text.padding = Padding(left: 8, top: 8, right: 14, bottom: 8)
        chatTheme.chatMessageBox.userMessage.text.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.text.outgoingLinkColor = UIColor.systemBlue

        // Тема для сообщения с файлом
        chatTheme.chatMessageBox.userMessage.file.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.file.textColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.file.dateColor = UIColor.black
        chatTheme.chatMessageBox.userMessage.file.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.file.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.file.padding = Padding(left: 8, top: 8, right: 14, bottom: 8)
        chatTheme.chatMessageBox.userMessage.file.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.file.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.file.outgoingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.userMessage.file.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.file.icon = StandardImages.insertDriveFile
        chatTheme.chatMessageBox.userMessage.file.iconBackgroundColor = UIColor(netHex: 0xDCEFD6)
        chatTheme.chatMessageBox.userMessage.file.fileNameColor = UIColor(netHex: 0xF4F5F7)
        chatTheme.chatMessageBox.userMessage.file.fileSizeColor = UIColor(netHex: 0xB9DEAD)

        // Тема для сообщения с изображением
        chatTheme.chatMessageBox.userMessage.image.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.image.textColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.image.dateColor = UIColor.black
        chatTheme.chatMessageBox.userMessage.image.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.image.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.image.padding = Padding(left: 8, top: 8, right: 14, bottom: 8)
        chatTheme.chatMessageBox.userMessage.image.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.image.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.image.outgoingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.userMessage.image.imageCornerRadius = 10
        chatTheme.chatMessageBox.userMessage.image.previewStyle = ImageMessageTheme.PreviewStyle.crop
        chatTheme.chatMessageBox.userMessage.image.textPadding = Padding(left: 10, top: 10, right: 16, bottom: 10)
        chatTheme.chatMessageBox.userMessage.image.padding = Padding(left: 10, top: 10, right: 16, bottom: 10)

        // Тема для голосового сообщения
        // Общее
        chatTheme.chatMessageBox.userMessage.voice.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.voice.textColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.voice.dateColor = UIColor.black
        chatTheme.chatMessageBox.userMessage.voice.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.voice.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.voice.incomingLinkColor = UIColor.systemBlue
        chatTheme.chatMessageBox.userMessage.voice.messageStatusIndicator = getMessageStatusIndicatorTheme()

        // Тема для голосового сообщения в баббле
        chatTheme.chatMessageBox.userMessage.voice.message.bubbleImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.voice.message.bubbleColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.message.playButton.icon = StandardImages.play
        chatTheme.chatMessageBox.userMessage.voice.message.playButton.iconColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.voice.message.playButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        chatTheme.chatMessageBox.userMessage.voice.message.pauseButton.icon = StandardImages.pause
        chatTheme.chatMessageBox.userMessage.voice.message.pauseButton.iconColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.voice.message.pauseButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        chatTheme.chatMessageBox.userMessage.voice.message.slider.cursorImage = StandardImages.thumb
        chatTheme.chatMessageBox.userMessage.voice.message.slider.cursorColor = UIColor.white
        chatTheme.chatMessageBox.userMessage.voice.message.slider.playBarColor = UIColor.gray.withAlphaComponent(0.2)
        chatTheme.chatMessageBox.userMessage.voice.message.slider.playedBarColor = UIColor.gray.withAlphaComponent(0.2)
        chatTheme.chatMessageBox.userMessage.voice.message.textSize = 14
        chatTheme.chatMessageBox.userMessage.voice.message.textFont = nil

        // Тема для превью голосового сообщения
        chatTheme.chatMessageBox.userMessage.voice.preview.playIcon = StandardImages.play
        chatTheme.chatMessageBox.userMessage.voice.preview.playIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.preview.pauseIcon = StandardImages.pause
        chatTheme.chatMessageBox.userMessage.voice.preview.pauseIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.preview.deleteIcon = StandardImages.delete
        chatTheme.chatMessageBox.userMessage.voice.preview.deleteIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.preview.slider.cursorImage = StandardImages.thumb
        chatTheme.chatMessageBox.userMessage.voice.preview.slider.cursorColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.preview.slider.playBarColor = UIColor.lightGray
        chatTheme.chatMessageBox.userMessage.voice.preview.slider.playedBarColor = UIColor.lightGray
        chatTheme.chatMessageBox.userMessage.voice.preview.textSize = 14
        chatTheme.chatMessageBox.userMessage.voice.preview.textFont = nil
        chatTheme.chatMessageBox.userMessage.voice.preview.textColor = UIColor.black

        // Тема для установки отступа сообщения от краев экрана
        chatTheme.chatMessageBox.userMessage.messageIndent = MessageIndentTheme(top: 0, leading: 0, trailing: 0, bottom: 0)

        return chatTheme.chatMessageBox.userMessage
    }
    
    // MARK: - Тема для статуса сообщения
    
    func getMessageStatusIndicatorTheme() -> MessageStatusIndicatorTheme {
        let chatTheme = ChatTheme()
        
        // Тема для статуса "Доставляется"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.image = StandardImages.unsentClock
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.size = CGSize(width: 12, height: 12)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.tintColor = UIColor.lightGray
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.altTintColor = UIColor.black

        // Тема для статуса "Доставлено"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.image = StandardImages.delivered
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.size = CGSize(width: 15, height: 15)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.tintColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.altTintColor = UIColor.black

        // Тема для статуса "Прочитано"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.image = StandardImages.read
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.size = CGSize(width: 15, height: 15)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.tintColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.altTintColor = UIColor.black

        // Тема для статуса "Ошибка"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.image = StandardImages.unsentError
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.size = CGSize(width: 15, height: 15)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.tintColor = UIColor.red
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.altTintColor = UIColor.red

        // Можно настроить индивидуально для каждого типа сообщения от клиента
        // Для примера выбрано текстовое сообщение от клиента (применится на все типы сообщения)
        return chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator
    }
    
    // MARK: - Тема для подсказки
    
    func getTooltipTheme() -> TooltipTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.tooltip.font = UIFont(name: "Futura-Medium", size: 13)
        chatTheme.chatMessageBox.tooltip.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.tooltip.textColor = UIColor(netHex: 0xF5F6F8)
        chatTheme.chatMessageBox.tooltip.borderColor = nil
        chatTheme.chatMessageBox.tooltip.borderWidth = nil
        chatTheme.chatMessageBox.tooltip.verticalInset = nil
        chatTheme.chatMessageBox.tooltip.horizontalInset = nil
        
        return chatTheme.chatMessageBox.tooltip
    }
    
    // MARK: - Тема для системного сообщения

    func getSystemMessageTheme() -> SystemMessageTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.systemMessage.backgroundColor = UIColor(red: 81, green: 82, blue: 82)
        chatTheme.chatMessageBox.systemMessage.backgroundRadius = 8
        chatTheme.chatMessageBox.systemMessage.textColor = UIColor.white
        chatTheme.chatMessageBox.systemMessage.font = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.systemMessage.textAlignment = NSTextAlignment.center
        chatTheme.chatMessageBox.systemMessage.offset = 20
        
        return chatTheme.chatMessageBox.systemMessage
    }
    
    // MARK: - Тема для приветственного сообщения

    func getInlinePrechatTheme() -> InlinePrechatTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.inlinePrechat.prechatIcon = StandardImages.inlinePrechatIcon
        chatTheme.chatMessageBox.inlinePrechat.prechatIconSize = CGSize(width: 25, height: 25)
        chatTheme.chatMessageBox.inlinePrechat.prechatIconTopIndent = 15
        chatTheme.chatMessageBox.inlinePrechat.prechatIconIndentToText = 15
        chatTheme.chatMessageBox.inlinePrechat.topIndent = 0
        chatTheme.chatMessageBox.inlinePrechat.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.inlinePrechat.textColor = UIColor.black
        chatTheme.chatMessageBox.inlinePrechat.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.inlinePrechat.viewAlignment = InlinePrechatTheme.Alignment.left
        chatTheme.chatMessageBox.inlinePrechat.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.inlinePrechat.cornerRadius = 15
        chatTheme.chatMessageBox.inlinePrechat.offset = 20
        
        return chatTheme.chatMessageBox.inlinePrechat
    }
    
    // MARK: - Тема для пречат-полей

    func getPrechatTheme() -> PrechatTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.backgroundColor = UIColor.white

        // Тема для заголовка пречат-полей
        chatTheme.chatMessageBox.prechat.prechatTitle = self.getPrechatTitleTheme()
        
        // Тема для заголовка пречат-поля
        chatTheme.chatMessageBox.prechat.fieldTitle = self.getPrechatFieldTitleTheme()
        
        // Тема для пречат-поля
        chatTheme.chatMessageBox.prechat.field = self.getPrechatFieldTheme()
        
        // Тема для поля вопроса
        chatTheme.chatMessageBox.prechat.questionField = self.getPrechatQuestionFieldTheme()
        
        // Тема для сообщения об ошибке
        chatTheme.chatMessageBox.prechat.errorLabel = self.getPrechatFieldErrorLabelTheme()
        
        // Тема для кнопки отправки пречат-полей
        chatTheme.chatMessageBox.prechat.sendButton = self.getPrechatSendButtonTheme()
        
        // Тема для кнопки вызова выпадающего списка в пречат-полях
        chatTheme.chatMessageBox.prechat.selector = self.getPrechatSelectorTheme()
        
        // Тема для кнопки назад в пречат-полях
        chatTheme.chatMessageBox.prechat.backButton = self.getPrechatBackButtonTheme()

        // Тема для вложения в пречат-полях
        chatTheme.chatMessageBox.prechat.attachment = self.getPrechatAttachmentTheme()

        return chatTheme.chatMessageBox.prechat
    }
    
    // MARK: - Тема для заголовка пречат-полей

    func getPrechatTitleTheme() -> PrechatTitleTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.prechatTitle.font = UIFont.systemFont(ofSize: 18)
        chatTheme.chatMessageBox.prechat.prechatTitle.fontSize = nil
        chatTheme.chatMessageBox.prechat.prechatTitle.textColor = UIColor.gray
        chatTheme.chatMessageBox.prechat.prechatTitle.textAlignment = NSTextAlignment.center
        chatTheme.chatMessageBox.prechat.prechatTitle.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.prechat.prechatTitle.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.prechatTitle.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        return chatTheme.chatMessageBox.prechat.prechatTitle
    }
    
    // MARK: - Тема для заголовка пречат-поля

    func getPrechatFieldTitleTheme() -> PrechatFieldTitleTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.fieldTitle.font = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.fieldTitle.fontSize = nil
        chatTheme.chatMessageBox.prechat.fieldTitle.textColor = UIColor.black
        chatTheme.chatMessageBox.prechat.fieldTitle.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.prechat.fieldTitle.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.prechat.fieldTitle.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.fieldTitle.requiredColor = UIColor.red

        return chatTheme.chatMessageBox.prechat.fieldTitle
    }
    
    // MARK: - Тема для пречат-поля

    func getPrechatFieldTheme() -> PrechatFieldTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.field.font = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.field.fontSize = nil
        chatTheme.chatMessageBox.prechat.field.textColor = UIColor.black
        chatTheme.chatMessageBox.prechat.field.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.prechat.field.errorFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.field.errorFontSize = nil
        chatTheme.chatMessageBox.prechat.field.errorTextColor = UIColor.black
        chatTheme.chatMessageBox.prechat.field.errorBorderColor = UIColor.red
        chatTheme.chatMessageBox.prechat.field.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.prechat.field.fieldHeight = 44
        chatTheme.chatMessageBox.prechat.field.cornerRadius = 8
        chatTheme.chatMessageBox.prechat.field.borderWidth = 0.5
        chatTheme.chatMessageBox.prechat.field.borderColor = UIColor.gray.withAlphaComponent(0.3)
        chatTheme.chatMessageBox.prechat.field.borderStyle = UITextField.BorderStyle.roundedRect
        chatTheme.chatMessageBox.prechat.field.keyboardAppearance = UIKeyboardAppearance.default

        return chatTheme.chatMessageBox.prechat.field
    }
    
    // MARK: - Тема для поля вопроса

    func getPrechatQuestionFieldTheme() -> PrechatQuestionFieldTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.questionField.font = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.questionField.fontSize = nil
        chatTheme.chatMessageBox.prechat.questionField.textColor = UIColor.black
        chatTheme.chatMessageBox.prechat.questionField.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.prechat.questionField.errorFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.questionField.errorFontSize = nil
        chatTheme.chatMessageBox.prechat.questionField.errorTextColor = UIColor.black
        chatTheme.chatMessageBox.prechat.questionField.errorBorderColor = UIColor.red
        chatTheme.chatMessageBox.prechat.questionField.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.prechat.questionField.fieldHeight = 44
        chatTheme.chatMessageBox.prechat.questionField.cornerRadius = 8
        chatTheme.chatMessageBox.prechat.questionField.borderWidth = 0.5
        chatTheme.chatMessageBox.prechat.questionField.borderColor = UIColor.gray.withAlphaComponent(0.3)
        chatTheme.chatMessageBox.prechat.questionField.borderStyle = UITextField.BorderStyle.roundedRect
        chatTheme.chatMessageBox.prechat.questionField.keyboardAppearance = UIKeyboardAppearance.default
        chatTheme.chatMessageBox.prechat.questionField.placeholderFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.questionField.placeholderTextColor = UIColor.lightGray

        return chatTheme.chatMessageBox.prechat.questionField
    }
    
    // MARK: - Тема для сообщения об ошибке

    func getPrechatFieldErrorLabelTheme() -> PrechatFieldErrorLabelTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.errorLabel.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.prechat.errorLabel.fontSize = nil
        chatTheme.chatMessageBox.prechat.errorLabel.textColor = UIColor(netHex: 0xFF2600)
        chatTheme.chatMessageBox.prechat.errorLabel.textAlignment = NSTextAlignment.left

        return chatTheme.chatMessageBox.prechat.errorLabel
    }
    
    // MARK: - Тема для кнопки отправки пречат-полей

    func getPrechatSendButtonTheme() -> PrechatSendButtonTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.sendButton.font = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.sendButton.textColor = UIColor(netHex: 0xF5F6F8)
        chatTheme.chatMessageBox.prechat.sendButton.textAlignment = UIControl.ContentHorizontalAlignment.center
        chatTheme.chatMessageBox.prechat.sendButton.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.prechat.sendButton.pressedColor = UIColor(netHex: 0x2980B9)
        chatTheme.chatMessageBox.prechat.sendButton.inactiveColor = UIColor(netHex: 0x95A5A6)
        chatTheme.chatMessageBox.prechat.sendButton.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.sendButton.contentInset = UIEdgeInsets.zero
        
        return chatTheme.chatMessageBox.prechat.sendButton
    }
    
    // MARK: - Тема для кнопки вызова выпадающего списка в пречат-полях

    func getPrechatSelectorTheme() -> PrechatSelectorTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.selector.cell.textFont = UIFont.systemFont(ofSize: 17)
        chatTheme.chatMessageBox.prechat.selector.cell.textFontSize = nil
        chatTheme.chatMessageBox.prechat.selector.cell.textColor = UIColor.black
        chatTheme.chatMessageBox.prechat.selector.cell.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.prechat.selector.cell.selectedBackgroundColor = nil
        
        chatTheme.chatMessageBox.prechat.selector.searchField.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.prechat.selector.searchField.inputFieldColor = UIColor(red: 0.46, green: 0.46, blue: 0.5, alpha: 0.12)
        chatTheme.chatMessageBox.prechat.selector.searchField.magnifierColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        chatTheme.chatMessageBox.prechat.selector.searchField.cursorColor = UIColor.systemBlue
        chatTheme.chatMessageBox.prechat.selector.searchField.clearButtonColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        chatTheme.chatMessageBox.prechat.selector.searchField.cancelButtonColor = UIColor.systemBlue
        chatTheme.chatMessageBox.prechat.selector.searchField.textFont = UIFont.preferredFont(forTextStyle: .body).withSize(17)
        chatTheme.chatMessageBox.prechat.selector.searchField.textColor = UIColor.black

        return chatTheme.chatMessageBox.prechat.selector
    }
    
    // MARK: - Тема для кнопки назад в пречат-полях

    func getPrechatBackButtonTheme() -> PrechatBackButtonTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.backButton.image = StandardImages.navigationBackButton
        chatTheme.chatMessageBox.prechat.backButton.size = CGSize(width: 20, height: 20)
        chatTheme.chatMessageBox.prechat.backButton.color = UIColor(netHex: 0x52AE30)
        
        return chatTheme.chatMessageBox.prechat.backButton
    }

    // MARK: – Тема для вложений в пречат-полях

    func getPrechatAttachmentTheme() -> PrechatAttachmentTheme {
        let chatTheme = ChatTheme()

        // Тема для кнопки вложения
        chatTheme.chatMessageBox.prechat.attachment.button.icon = StandardImages.attachIcon
        chatTheme.chatMessageBox.prechat.attachment.button.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.prechat.attachment.button.iconColorPressed = UIColor.black
        chatTheme.chatMessageBox.prechat.attachment.button.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.prechat.attachment.button.backgroundPressedColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.prechat.attachment.button.size = CGSize(width: 40, height: 40)
        chatTheme.chatMessageBox.prechat.attachment.button.cornerRadius = 20

        // Тема для панели вложений
        chatTheme.chatMessageBox.prechat.attachment.panel.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.prechat.attachment.panel.leftPadding = 20
        chatTheme.chatMessageBox.prechat.attachment.panel.leftPadding = 30
        chatTheme.chatMessageBox.prechat.attachment.panel.spacing = 12
        chatTheme.chatMessageBox.prechat.attachment.panel.image.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.prechat.attachment.panel.image.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.attachment.panel.title.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.prechat.attachment.panel.title.textColor = UIColor.black
        chatTheme.chatMessageBox.prechat.attachment.panel.dismissButton.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.prechat.attachment.panel.dismissButton.icon = StandardImages.trash
        chatTheme.chatMessageBox.prechat.attachment.panel.dismissButton.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.prechat.attachment.panel.dismissButton.size = CGSize(width: 20, height: 20)
        chatTheme.chatMessageBox.prechat.attachment.panel.dismissButton.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.attachment.panel.dismissButton.imageInset = UIEdgeInsets.zero

        return chatTheme.chatMessageBox.prechat.attachment
    }

    // MARK: - Тема для панели ввода
    
    func getInputPanelTheme() -> InputTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.background = UIColor(netHex: 0xF5F6F8)
        
        // Тема для поля ввода
        chatTheme.chatMessageBox.input.textView = self.getInputPanelTextViewTheme()
        
        // Тема для кнпоки прикрепления вложения
        chatTheme.chatMessageBox.input.attach = self.getInputPanelAttachButtonTheme()
        
        // Тема для кнопки отправки сообщения
        chatTheme.chatMessageBox.input.send = self.getInputPanelSendButtonTheme()
        
        // Тема для таймера голосового сообщения
        chatTheme.chatMessageBox.input.timer = self.getInputPanelTimerTheme()
        
        // Тема для кнопки отмены голосового сообщения
        chatTheme.chatMessageBox.input.cancelEntry = self.getInputPanelCancelEntryButtonTheme()
        
        // Тема для кнопки закрепления голосового сообщения
        chatTheme.chatMessageBox.input.lock = self.getInputPanelLockButtonTheme()
        
        return chatTheme.chatMessageBox.input
    }
    
    // MARK: - Тема для поля ввода
    
    func getInputPanelTextViewTheme() -> InputTheme.TextViewTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.textView.font = nil
        chatTheme.chatMessageBox.input.textView.fontColor = UIColor.black
        chatTheme.chatMessageBox.input.textView.placeholderFontColor = UIColor.gray
        chatTheme.chatMessageBox.input.textView.cursorColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.textView.borderColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.textView.borderWidth = 1
        chatTheme.chatMessageBox.input.textView.borderRadius = 20
        chatTheme.chatMessageBox.input.textView.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.input.textView.height = 40
        chatTheme.chatMessageBox.input.textView.textInset = UIEdgeInsets(top: 10, left: 8, bottom: 6, right: 8)
        chatTheme.chatMessageBox.input.textView.padding = UIEdgeInsets(top: 10, left: 56, bottom: 10, right: 56)
        chatTheme.chatMessageBox.input.textView.minLeftPadding = 8
        chatTheme.chatMessageBox.input.textView.keyboardAppearance = UIKeyboardAppearance.light

        return chatTheme.chatMessageBox.input.textView
    }
    
    // MARK: - Тема для кнпоки прикрепления вложения
    
    func getInputPanelAttachButtonTheme() -> InputTheme.AttachTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.attach.icon = StandardImages.attachIcon
        chatTheme.chatMessageBox.input.attach.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.attach.iconColorPressed = UIColor.black
        chatTheme.chatMessageBox.input.attach.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.input.attach.backgroundPressedColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.attach.size = CGSize(width: 40, height: 40)
        chatTheme.chatMessageBox.input.attach.cornerRadius = 20
        
        return chatTheme.chatMessageBox.input.attach
    }
    
    // MARK: - Тема для кнопки отправки сообщения
    
    func getInputPanelSendButtonTheme() -> InputTheme.SendTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.send.icon = StandardImages.sendIcon
        chatTheme.chatMessageBox.input.send.iconColor = UIColor.white
        chatTheme.chatMessageBox.input.send.iconColorPressed = UIColor.black
        chatTheme.chatMessageBox.input.send.iconColorDisabled = UIColor.white
        chatTheme.chatMessageBox.input.send.voiceIcon = StandardImages.sendVoiceIcon
        chatTheme.chatMessageBox.input.send.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.send.backgroundPressedColor = UIColor(netHex: 0x0FD10F)
        chatTheme.chatMessageBox.input.send.backgroundDisabledColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.send.size = CGSize(width: 40, height: 40)
        chatTheme.chatMessageBox.input.send.cornerRadius = 20
        
        return chatTheme.chatMessageBox.input.send
    }
    
    // MARK: - Тема для таймера голосового сообщения
    
    func getInputPanelTimerTheme() -> InputTheme.TimerTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.timer.font = nil
        chatTheme.chatMessageBox.input.timer.fontSize = 13
        chatTheme.chatMessageBox.input.timer.fontColor = UIColor.black

        return chatTheme.chatMessageBox.input.timer
    }
    
    // MARK: - Тема для кнопки отмены голосового сообщения
    
    func getInputPanelCancelEntryButtonTheme() -> InputTheme.CancelEntryTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.cancelEntry.icon = StandardImages.cancelEntry
        chatTheme.chatMessageBox.input.cancelEntry.iconColor = UIColor.black
        chatTheme.chatMessageBox.input.cancelEntry.textFont = nil
        chatTheme.chatMessageBox.input.cancelEntry.textFontSize = 13
        chatTheme.chatMessageBox.input.cancelEntry.textColor = UIColor.black

        return chatTheme.chatMessageBox.input.cancelEntry
    }
    
    // MARK: - Тема для кнопки закрепления голосового сообщения
    
    func getInputPanelLockButtonTheme() -> InputTheme.LockTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.lock.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.lock.imageColor = UIColor.white
        chatTheme.chatMessageBox.input.lock.swipeDirectionImageColor = UIColor.white

        return chatTheme.chatMessageBox.input.lock
    }

    // MARK: - Тема для панели превью цитирования сообщения
    func getReplyMessageTheme() -> ReplyMessageTheme {
        let chatTheme = ChatTheme()

        // Тема для панели превью
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.textFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.lineSpacing = 0
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageTextColor = UIColor(netHex: 0x222733)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageSenderNameColor = UIColor(netHex: 0x222733)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageCancelButtonImage = StandardImages.cancelReply
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageCancelButtonSize = CGSize(width: 16, height: 16)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageCancelButtonColor = UIColor(netHex: 0x7B829A)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageIconColor = UIColor(netHex: 0xAFB3C0)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageIconSize = CGSize(width: 16, height: 16)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageAttachmentTintColor = UIColor(netHex: 0xE8E9EC)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessagePreviewPanelTheme.replyMessageAttachmentBackgroundColor = UIColor(netHex: 0x52AE30)

        // Тема для области автора цитаты
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageSenderTheme.operatorColor = UIColor.black
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageSenderTheme.clientColor = UIColor.white
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageSenderTheme.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageSenderTheme.lineSpacing = 3

        // Тема для области сообщения
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageAreaTheme.operatorTextColor = UIColor.black.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageAreaTheme.clientTextColor = UIColor.white.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageAreaTheme.textFont = UIFont.systemFont(ofSize: 13)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageAreaTheme.lineSpacing = 3
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageAreaTheme.clientIconColor = UIColor.white.withAlphaComponent(0.72)
        chatTheme.chatMessageBox.replyMessageTheme.replyMessageAreaTheme.operatorIconColor = UIColor.black.withAlphaComponent(0.72)

        return chatTheme.chatMessageBox.replyMessageTheme
    }

    // MARK: - Тема для панели вложения
    
    func getAttachmentPanelTheme() -> AttachmentPanelTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.attachment.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.attachment.leftPadding = 12
        chatTheme.chatMessageBox.attachment.rightPadding = 12
        chatTheme.chatMessageBox.attachment.spacing = 12
        chatTheme.chatMessageBox.attachment.image.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.attachment.image.cornerRadius = 0
        chatTheme.chatMessageBox.attachment.title.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.attachment.title.textColor = UIColor.black
        chatTheme.chatMessageBox.attachment.dismissButton.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.attachment.dismissButton.icon = StandardImages.trash
        chatTheme.chatMessageBox.attachment.dismissButton.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.attachment.dismissButton.size = CGSize(width: 20, height: 20)
        chatTheme.chatMessageBox.attachment.dismissButton.cornerRadius = 0
        chatTheme.chatMessageBox.attachment.dismissButton.imageInset = UIEdgeInsets.zero

        return chatTheme.chatMessageBox.attachment
    }
    
    // MARK: - Тема для кнопки начала нового диалога

    func getNewDialogTheme() -> NewDialogTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.newDialog.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.newDialog.textFont = nil
        chatTheme.chatMessageBox.newDialog.textColor = UIColor.black
        chatTheme.chatMessageBox.newDialog.edgeInsets = UIEdgeInsets.zero
        chatTheme.chatMessageBox.newDialog.cornerRadius = 0
        
        return chatTheme.chatMessageBox.newDialog
    }
    
    // MARK: - Тема для сообщения "Оператор печатает..."
    
    func getAgentTypingStatusTheme() -> AgentTypingStatusTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.agentTypingStatus.fontColor = UIColor.systemGray
        chatTheme.chatMessageBox.agentTypingStatus.font = nil
        
        return chatTheme.chatMessageBox.agentTypingStatus
    }

    // MARK: - Тема для NavigationBar
    
    func getNavigationBarTheme() -> NavigationBarTheme {
        let chatTheme = ChatTheme()
        
        // На экране пречат-полей
        chatTheme.chatMessageBox.navigationBar.prechat.barTintColor = UIColor.white
        chatTheme.chatMessageBox.navigationBar.prechat.tintColor = UIColor.black
        chatTheme.chatMessageBox.navigationBar.prechat.titleFont = UIFont.systemFont(ofSize: 16)
        chatTheme.chatMessageBox.navigationBar.prechat.titleColor = UIColor.black

        // На экране селектора в пречат-полях
        chatTheme.chatMessageBox.navigationBar.prechatSelector.barTintColor = UIColor.white
        chatTheme.chatMessageBox.navigationBar.prechatSelector.tintColor = UIColor.black
        chatTheme.chatMessageBox.navigationBar.prechatSelector.titleFont = UIFont.systemFont(ofSize: 16)
        chatTheme.chatMessageBox.navigationBar.prechatSelector.titleColor = UIColor.black

        return chatTheme.chatMessageBox.navigationBar
    }
    
    // MARK: - Тема для отправки истории диалога на почту
    
    func getSendHistoryTheme() -> SendHistoryTheme {
        let chatTheme = ChatTheme()
        
        // Кнопка в NavigationBar
        chatTheme.chatMessageBox.sendHistory.navBarButton.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.sendHistory.navBarButton.image = StandardImages.sendHistory
        chatTheme.chatMessageBox.sendHistory.navBarButton.imageColor = UIColor.gray
        chatTheme.chatMessageBox.sendHistory.navBarButton.imageInset = UIEdgeInsets.zero
        chatTheme.chatMessageBox.sendHistory.navBarButton.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.sendHistory.navBarButton.cornerRadius = 0
        
        // Панель
        chatTheme.chatMessageBox.sendHistory.panel.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.sendHistory.panel.cornerRadius = 15
        chatTheme.chatMessageBox.sendHistory.panel.barColor = UIColor(netHex: 0xD2D5D9)
        
        // Поле ввода почты
        chatTheme.chatMessageBox.sendHistory.panel.emailView.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.sendHistory.panel.emailView.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.sendHistory.panel.emailView.textColor = UIColor.black
        chatTheme.chatMessageBox.sendHistory.panel.emailView.borderColor = UIColor.gray.withAlphaComponent(0.3)
        chatTheme.chatMessageBox.sendHistory.panel.emailView.borderWidth = 0.5
        chatTheme.chatMessageBox.sendHistory.panel.emailView.cornerRadius = 8
        chatTheme.chatMessageBox.sendHistory.panel.emailView.keyboardAppearance = UIKeyboardAppearance.default

        // Кнопка отправки
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.tintColor = UIColor.white
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.font = UIFont.systemFont(ofSize: 16)
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.cornerRadius = 25
        
        // Лоадер
        chatTheme.chatMessageBox.sendHistory.panel.loader.tintColor = UIColor(netHex: 0x52AE30)
        
        // Сообщение в случае ошибки
        chatTheme.chatMessageBox.sendHistory.panel.error.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.sendHistory.panel.error.textColor = UIColor(netHex: 0xFF2600)
        chatTheme.chatMessageBox.sendHistory.panel.error.textAlignment = NSTextAlignment.left

        // Сообщение в случае успеха
        chatTheme.chatMessageBox.sendHistory.panel.success.font = UIFont.systemFont(ofSize: 16)
        chatTheme.chatMessageBox.sendHistory.panel.success.textColor = UIColor.gray
        chatTheme.chatMessageBox.sendHistory.panel.success.textAlignment = NSTextAlignment.center

        return chatTheme.chatMessageBox.sendHistory
    }
    
    // MARK: - Тема для видеозвонка
    
    func getVideoCallTheme() -> VideoCallTheme {
        let chatTheme = ChatTheme()
        
        // Кнопка в NavigationBar
        chatTheme.chatMessageBox.videoCall.navBarButton.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.videoCall.navBarButton.image = StandardImages.videoCall
        chatTheme.chatMessageBox.videoCall.navBarButton.imageColor = UIColor.gray
        chatTheme.chatMessageBox.videoCall.navBarButton.imageInset = UIEdgeInsets.zero
        chatTheme.chatMessageBox.videoCall.navBarButton.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.videoCall.navBarButton.cornerRadius = 0
        
        return chatTheme.chatMessageBox.videoCall
    }

    // MARK: - Тема для окна оценки диалога
    
    func getRatingScreenTheme() -> RatingScreenTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.ratingScreen.background = UIColor(netHex: 0xF0F0F8)
        
        // Кнопка подтверждения
        chatTheme.chatMessageBox.ratingScreen.submitButton.bgColor = UIColor(netHex: 0x50A82F)
        chatTheme.chatMessageBox.ratingScreen.submitButton.bgColorPressed = UIColor(netHex: 0x3E8423)
        chatTheme.chatMessageBox.ratingScreen.submitButton.bgColorDisabled = UIColor(netHex: 0x90C77B)
        chatTheme.chatMessageBox.ratingScreen.submitButton.textColor = UIColor(netHex: 0xFFFFFF)
        chatTheme.chatMessageBox.ratingScreen.submitButton.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.ratingScreen.submitButton.padding = Padding(left: 0, top: 16, right: 0, bottom: 16)
        chatTheme.chatMessageBox.ratingScreen.submitButton.buttonBorderRadius = 16
        chatTheme.chatMessageBox.ratingScreen.submitButton.iconColor = nil
        chatTheme.chatMessageBox.ratingScreen.submitButton.iconColorPressed = nil
        chatTheme.chatMessageBox.ratingScreen.submitButton.iconColorDisabled = nil
        
        // Кнопка отмены
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.bgColor = UIColor(netHex: 0xFFFFFF)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.bgColorPressed = UIColor(netHex: 0xE2E2E2)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.bgColorDisabled = UIColor(netHex: 0xFFFFFF)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.textColor = UIColor(netHex: 0x50A82F)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.padding = Padding(left: 0, top: 16, right: 0, bottom: 16)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.buttonBorderRadius = 16
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.iconColor = nil
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.iconColorPressed = nil
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.iconColorDisabled = nil
        
        // Текст
        chatTheme.chatMessageBox.ratingScreen.text.font = UIFont.systemFont(ofSize: 25)
        chatTheme.chatMessageBox.ratingScreen.text.color = UIColor.black

        // Подсказка
        chatTheme.chatMessageBox.ratingScreen.ratingTooltip.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.ratingScreen.ratingTooltip.textFont = UIFont(name: "Futura-Medium", size: 13)
        chatTheme.chatMessageBox.ratingScreen.ratingTooltip.textColor = UIColor.black
        chatTheme.chatMessageBox.ratingScreen.ratingTooltip.textPadding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        chatTheme.chatMessageBox.ratingScreen.ratingTooltip.cornerRadius = 16

        // Тема для звездочек
        chatTheme.chatMessageBox.ratingScreen.stars.colorFilled = UIColor(netHex: 0xFFE025)
        chatTheme.chatMessageBox.ratingScreen.stars.borderWidthFilled = 2
        chatTheme.chatMessageBox.ratingScreen.stars.borderColorFilled = UIColor(netHex: 0xFFE025)
        chatTheme.chatMessageBox.ratingScreen.stars.colorEmpty = UIColor.white
        chatTheme.chatMessageBox.ratingScreen.stars.borderColorEmpty = UIColor(netHex: 0x686B70)
        chatTheme.chatMessageBox.ratingScreen.stars.borderWidthEmpty = 2
        chatTheme.chatMessageBox.ratingScreen.stars.starSize = 30
        chatTheme.chatMessageBox.ratingScreen.stars.filledImage = nil
        chatTheme.chatMessageBox.ratingScreen.stars.emptyImage = nil
        
        return chatTheme.chatMessageBox.ratingScreen
    }
    
    // MARK: - Тема для сообщения с оценкой диалога
    
    func getRateResponseTheme() -> RateResponseTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.rateResponse.stars.colorFilled = UIColor(netHex: 0xFFE025)
        chatTheme.chatMessageBox.rateResponse.stars.borderWidthFilled = 2
        chatTheme.chatMessageBox.rateResponse.stars.borderColorFilled = UIColor(netHex: 0xFFE025)
        chatTheme.chatMessageBox.rateResponse.stars.colorEmpty = UIColor.white
        chatTheme.chatMessageBox.rateResponse.stars.borderColorEmpty = UIColor(netHex: 0x686B70)
        chatTheme.chatMessageBox.rateResponse.stars.borderWidthEmpty = 2
        chatTheme.chatMessageBox.rateResponse.stars.starSize = 30
        chatTheme.chatMessageBox.rateResponse.stars.filledImage = nil
        chatTheme.chatMessageBox.rateResponse.stars.emptyImage = nil
        
        return chatTheme.chatMessageBox.rateResponse
    }

    // MARK: - Тема для панели автодополнений
    
    func getAutocompleteTheme() -> AutocompleteTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.autocomplete.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.autocomplete.textColor = UIColor.black
        chatTheme.chatMessageBox.autocomplete.borderColor = UIColor.lightGray
        chatTheme.chatMessageBox.autocomplete.padding = Padding(left: 8, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.autocomplete.textAlignment = NSTextAlignment.center
        chatTheme.chatMessageBox.autocomplete.fontSize = nil
        chatTheme.chatMessageBox.autocomplete.font = nil
        
        return chatTheme.chatMessageBox.autocomplete
    }
    
    // MARK: - Тема для отображаемой ошибки (кроме экрана чата)
    
    func getErrorTheme() -> ChatErrorTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.error.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.error.backgroundImage = nil
        chatTheme.chatMessageBox.error.cornerRadius = 15
        chatTheme.chatMessageBox.error.textFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.error.textColor = UIColor.black
        chatTheme.chatMessageBox.error.textAlignment = NSTextAlignment.natural
        chatTheme.chatMessageBox.error.textPadding = nil
        chatTheme.chatMessageBox.error.bubbleMargin = nil
        chatTheme.chatMessageBox.error.needShadow = true
        
        return chatTheme.chatMessageBox.error
    }
    
    // MARK: - Тема для отображаемой ошибки на экране чата
    
    func getChatErrorTheme() -> ChatErrorTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.chatError.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.chatError.backgroundImage = nil
        chatTheme.chatMessageBox.chatError.cornerRadius = 15
        chatTheme.chatMessageBox.chatError.textFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.chatError.textColor = UIColor.black
        chatTheme.chatMessageBox.chatError.textAlignment = NSTextAlignment.natural
        chatTheme.chatMessageBox.chatError.textPadding = nil
        chatTheme.chatMessageBox.chatError.bubbleMargin = nil
        chatTheme.chatMessageBox.chatError.needShadow = true
        
        return chatTheme.chatMessageBox.chatError
    }
    
    // MARK: - Тема для разделителя с датой
    
    func getChatDateTheme() -> ChatDateTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.chatDate.font = nil
        chatTheme.chatMessageBox.chatDate.fontSize = nil
        chatTheme.chatMessageBox.chatDate.floatingDivider.textColor = UIColor.gray
        chatTheme.chatMessageBox.chatDate.floatingDivider.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.chatDate.fixedDivider.textColor = UIColor.gray
        chatTheme.chatMessageBox.chatDate.fixedDivider.backgroundColor = UIColor(netHex: 0xE6E7E8)
        chatTheme.chatMessageBox.chatDate.isUppercased = false
        chatTheme.chatMessageBox.chatDate.cornerRadius = 8
        chatTheme.chatMessageBox.chatDate.padding = Padding(left: 8, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.chatDate.textPadding = Padding(left: 8, top: 8, right: 8, bottom: 8)

        return chatTheme.chatMessageBox.chatDate
    }
    
    // MARK: - Тема для контроллера выбора типа вложения
    
    func getAttachPopupControllerTheme() -> AttachPopupTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.popupControllerStyle.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.popupControllerStyle.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.popupControllerStyle.font = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.popupControllerStyle.textColor = UIColor.darkGray
        chatTheme.chatMessageBox.popupControllerStyle.cancelFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.popupControllerStyle.cancelTextColor = UIColor.darkGray
        chatTheme.chatMessageBox.popupControllerStyle.contentInset.left = 20
        chatTheme.chatMessageBox.popupControllerStyle.contentInset.right = 20
        chatTheme.chatMessageBox.popupControllerStyle.contentInset.bottom = 20
        
        return chatTheme.chatMessageBox.popupControllerStyle
    }
    
    // MARK: - Тема для сообщения о том, что витрина оффлайн
    
    func getOfflineMessageTheme() -> OfflineMessageTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.offlineMessage.textColor = UIColor.lightGray
        chatTheme.chatMessageBox.offlineMessage.textFont = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.offlineMessage.textAlignment = NSTextAlignment.center
        chatTheme.chatMessageBox.offlineMessage.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.offlineMessage.cornerRadius = 0
        chatTheme.chatMessageBox.offlineMessage.padding = Padding(left: 16, top: 12, right: 16, bottom: 12)
        chatTheme.chatMessageBox.offlineMessage.textInset = Padding(left: 0, top: 0, right: 0, bottom: 0)
        
        return chatTheme.chatMessageBox.offlineMessage
    }
    
    // MARK: - Тема для сообщения о том, что витрина заблокирована
    
    func getShowcaseBlockedPanelTheme() -> ShowcaseBlockedPanelTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.showcaseBlockedPanel.textColor = UIColor(netHex: 0x777C87)
        chatTheme.chatMessageBox.showcaseBlockedPanel.textFont = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.showcaseBlockedPanel.textAlignment = NSTextAlignment.center
        chatTheme.chatMessageBox.showcaseBlockedPanel.image = StandardImages.showcaseBlocked
        chatTheme.chatMessageBox.showcaseBlockedPanel.imageColor = UIColor(netHex: 0x95909E).withAlphaComponent(0.5)
        chatTheme.chatMessageBox.showcaseBlockedPanel.backgroundColor = UIColor(netHex: 0xF5F6F8)
        chatTheme.chatMessageBox.showcaseBlockedPanel.textInset = Padding(left: 0, top: 0, right: 0, bottom: 0)
        
        return chatTheme.chatMessageBox.showcaseBlockedPanel
    }

    // MARK: - Тема для опросника

    func getQuestionaryTheme() -> QuestionnaireTheme {
        let chatTheme = ChatTheme()

        chatTheme.chatMessageBox.questionnaire.backgroundColor = UIColor.white

        // Тема для заголовка опросника
        chatTheme.chatMessageBox.questionnaire.title.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.questionnaire.title.font = UIFont.boldSystemFont(ofSize: 20)
        chatTheme.chatMessageBox.questionnaire.title.textColor = UIColor.black
        chatTheme.chatMessageBox.questionnaire.title.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.questionnaire.title.cornerRadius = 0
        chatTheme.chatMessageBox.questionnaire.title.padding = UIEdgeInsets(top: 36, left: 12, bottom: 24, right: 12)

        // Тема для поля опросника
        chatTheme.chatMessageBox.questionnaire.field.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.questionnaire.field.height = 46
        chatTheme.chatMessageBox.questionnaire.field.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        chatTheme.chatMessageBox.questionnaire.field.textColor = UIColor.black
        chatTheme.chatMessageBox.questionnaire.field.placeholderTextColor = UIColor.lightGray
        chatTheme.chatMessageBox.questionnaire.field.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.questionnaire.field.tintColor = UIColor(netHex: 0x777C87)
        chatTheme.chatMessageBox.questionnaire.field.keyboardAppearance = UIKeyboardAppearance.default
        chatTheme.chatMessageBox.questionnaire.field.lineColor = UIColor.gray
        chatTheme.chatMessageBox.questionnaire.field.title.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        chatTheme.chatMessageBox.questionnaire.field.title.textColor = UIColor(netHex: 0x777C87)
        chatTheme.chatMessageBox.questionnaire.field.title.textAlignment = NSTextAlignment.left
        chatTheme.chatMessageBox.questionnaire.field.title.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.questionnaire.field.title.cornerRadius = 0
        chatTheme.chatMessageBox.questionnaire.field.title.requiredColor = UIColor.red
        chatTheme.chatMessageBox.questionnaire.field.error.font = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.questionnaire.field.error.textColor = UIColor.red
        chatTheme.chatMessageBox.questionnaire.field.error.lineColor = UIColor.red

        // Тема для кнопки отправки опросника
        chatTheme.chatMessageBox.questionnaire.sendButton.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        chatTheme.chatMessageBox.questionnaire.sendButton.textColor = UIColor.white
        chatTheme.chatMessageBox.questionnaire.sendButton.textAlignment = UIControl.ContentHorizontalAlignment.center
        chatTheme.chatMessageBox.questionnaire.sendButton.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.questionnaire.sendButton.pressedColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.questionnaire.sendButton.cornerRadius = 22
        chatTheme.chatMessageBox.questionnaire.sendButton.contentInset = UIEdgeInsets.zero
        chatTheme.chatMessageBox.questionnaire.sendButton.height = 44

        // Тема для кнопки отмены опросника
        chatTheme.chatMessageBox.questionnaire.cancelButton.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.questionnaire.cancelButton.textColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.questionnaire.cancelButton.textAlignment = UIControl.ContentHorizontalAlignment.center
        chatTheme.chatMessageBox.questionnaire.cancelButton.backgroundColor = UIColor.clear
        chatTheme.chatMessageBox.questionnaire.cancelButton.pressedColor = UIColor.clear
        chatTheme.chatMessageBox.questionnaire.cancelButton.cornerRadius = 0
        chatTheme.chatMessageBox.questionnaire.cancelButton.contentInset = UIEdgeInsets.zero
        chatTheme.chatMessageBox.questionnaire.cancelButton.height = 18

        return chatTheme.chatMessageBox.questionnaire
    }
    
    // MARK: - Тема для кнопки прокрутки истории диалога
    
    func getScrollDownArrowTheme() -> ScrollDownArrowTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.scrollDownArrow.image = StandardImages.arrowDown
        chatTheme.chatMessageBox.scrollDownArrow.imageColor = UIColor(netHex: 0xCCCCCC)
        chatTheme.chatMessageBox.scrollDownArrow.backgroundColor = UIColor.white
        chatTheme.chatMessageBox.scrollDownArrow.size = CGSize(width: 36, height: 36)
        chatTheme.chatMessageBox.scrollDownArrow.cornerRadius = 18
        chatTheme.chatMessageBox.scrollDownArrow.imageInset = UIEdgeInsets(top: -1.5, left: -1.5, bottom: -1.5, right: -1.5)
        
        return chatTheme.chatMessageBox.scrollDownArrow
    }
    
    // MARK: - Тема для контекстного меню
    
    func getContextMenuTheme() -> ContextMenuTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.contextMenu.copyImage = StandardImages.copyMessage
        chatTheme.chatMessageBox.contextMenu.resendImage = StandardImages.resendMessage
        chatTheme.chatMessageBox.contextMenu.deleteImage = StandardImages.deleteMessage
        chatTheme.chatMessageBox.contextMenu.cornerRadius = 16
        
        // Тема для уведомления о том, что выбранное сообщение было скопировано
        chatTheme.chatMessageBox.contextMenu.messageCopied.visibilityTimeout = 1
        chatTheme.chatMessageBox.contextMenu.messageCopied.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        chatTheme.chatMessageBox.contextMenu.messageCopied.cornerRadius = 15
        chatTheme.chatMessageBox.contextMenu.messageCopied.textFont = UIFont.systemFont(ofSize: 15)
        chatTheme.chatMessageBox.contextMenu.messageCopied.textColor = UIColor.white
        chatTheme.chatMessageBox.contextMenu.messageCopied.textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        chatTheme.chatMessageBox.contextMenu.messageCopied.bubbleMargin = nil
        
        return chatTheme.chatMessageBox.contextMenu
    }
    
}

