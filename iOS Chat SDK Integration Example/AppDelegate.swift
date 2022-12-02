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
        VoiceMessageSettings.shared.setupSettings(sendMessageAfterReleasingIsOn: true,
                                           sendMessageAfterStopButtonTapIsOn: true,
                                           showVoiceMessageInChatIsOn: false)
        
        // Настройка таймаутов видеозвонка
        VideoCallSettings.shared.setupSettings(callConnectionTimeout: 30,
                                               networkConnectionTimeout: 5)
        
        // Установка расположения положения лейбла "Оператор печатает" Сверху(в NavigationBar) / Снизу(Над строкой ввода сообщения)
        OperatorTypingLabelLocationSettings.shared.setLocation(.bottom)
        
        // Установка расположения времени и статуса, имени оператора в/вне облака сообщения
        MessageBubbleSettings.shared.setupSettings(timeAndStatusInBubble: false, operatorNameInBubble: false)
        
        // Установка отображения затемнения при вызове меню вложений
        PopupBlackoutSettings.shared.setupSettings(true)
        
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
        let deviceID = UIDevice.current.identifierForVendor?.uuidString

        var data: [String: String] = [:]

        // Передача токена для push-уведомлений
        data.updateValue("<токен для push-уведомлений>", forKey: "APP_PUSH_ID")
        
        // Передача данных авторизации
        let authData = NChatSDKAuthData(crmId: deviceID!, data: data)
        
        // Инициализация NChatSDKService
        // showcase - идентификатор витрины
        // handler - обработчик событий
        // authData - данные авторизации
        // url - адрес сервера ("https://" + <api host>)
        // wsUrl - адрес websocket ("wss://" + <websocket host>)
        // theme - тема для чата
        let chatSDKService = NChatSDKService(showcaseId: ,
                    handler: Handler(),
                    authData: authData,
                    url: ,
                    wsUrl: ,
                    theme: getTheme())

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
        
        // Тема для сообщения с кнопками
        chatTheme.chatMessageBox.messageButton = self.getMessageButtonTheme()
        
        // Тема для сообщения с кнопкой вызова выпадающего списка
        chatTheme.chatMessageBox.selectorButton = self.getSelectorButtonTheme()
        
        // Тема для системного сообщения
        chatTheme.chatMessageBox.systemMessage = self.getSystemMessageTheme()
        
        // Тема для приветственного сообщения
        chatTheme.chatMessageBox.inlinePrechat = self.getInlinePrechatTheme()
        
        // Тема для пречат-полей
        chatTheme.chatMessageBox.prechat = self.getPrechatTheme()
        
        // Тема для панели ввода
        chatTheme.chatMessageBox.input = self.getInputPanelTheme()
        
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

        // Тема для кнопки оценки диалога
        chatTheme.chatMessageBox.chatRating = self.getRatingButtonTheme()

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
        
        // Тема для поля опросника
        chatTheme.chatMessageBox.questionaryField = self.getQuestionaryFieldTheme()
        
        // Тема для окна благодарности за прохождение опроса
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme = self.getQuestionaryGratitudeScreenTheme()
        
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
        chatTheme.chatMessageBox.operatorMessage.outgoingDateViewAlignment = .right
        
        // Тема для текстового сообщения
        chatTheme.chatMessageBox.operatorMessage.text.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.text.textColor = .black
        chatTheme.chatMessageBox.operatorMessage.text.dateColor = .black
        chatTheme.chatMessageBox.operatorMessage.text.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.text.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.text.padding = Padding(left: 14, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.operatorMessage.text.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.text.incomingLinkColor = .systemBlue
        
        // Тема для сообщения c файлом
        chatTheme.chatMessageBox.operatorMessage.file.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.file.textColor = .black
        chatTheme.chatMessageBox.operatorMessage.file.dateColor = .black
        chatTheme.chatMessageBox.operatorMessage.file.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.file.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.file.padding = Padding(left: 14, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.operatorMessage.file.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.file.incomingLinkColor = .systemBlue
        chatTheme.chatMessageBox.operatorMessage.file.iconColor = UIColor(netHex: 0xE8E9EC)
        chatTheme.chatMessageBox.operatorMessage.file.icon = StandardImages.insertDriveFile
        chatTheme.chatMessageBox.operatorMessage.file.iconBackgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.file.fileNameColor = .black
        chatTheme.chatMessageBox.operatorMessage.file.fileSizeColor = UIColor(netHex: 0x767676)
        
        // Тема для сообщения c изображением
        chatTheme.chatMessageBox.operatorMessage.image.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.image.textColor = .black
        chatTheme.chatMessageBox.operatorMessage.image.dateColor = .black
        chatTheme.chatMessageBox.operatorMessage.image.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.image.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.image.padding = Padding(left: 14, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.operatorMessage.image.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.image.incomingLinkColor = .systemBlue
        chatTheme.chatMessageBox.operatorMessage.image.imageCornerRadius = 10
        chatTheme.chatMessageBox.operatorMessage.image.textPadding = Padding(left: 10, top: 10, right: 16, bottom: 10)
        chatTheme.chatMessageBox.operatorMessage.image.padding = Padding(left: 16, top: 10, right: 10, bottom: 10)
        
        // Тема для голосового сообщения
        chatTheme.chatMessageBox.operatorMessage.voice.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.voice.textColor = .black
        chatTheme.chatMessageBox.operatorMessage.voice.dateColor = .black
        chatTheme.chatMessageBox.operatorMessage.voice.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.operatorMessage.voice.backgroundColor = UIColor(netHex: 0xE3E3E3)
        chatTheme.chatMessageBox.operatorMessage.voice.backgroundImage = StandardImages.bubbleIncoming
        chatTheme.chatMessageBox.operatorMessage.voice.incomingLinkColor = .systemBlue
        chatTheme.chatMessageBox.operatorMessage.voice.playIcon = StandardImages.play
        chatTheme.chatMessageBox.operatorMessage.voice.pauseIcon = StandardImages.pause
        chatTheme.chatMessageBox.operatorMessage.voice.playIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.pauseIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.buttonTopIndent = 13
        chatTheme.chatMessageBox.operatorMessage.voice.buttonLeftIndent = 5
        chatTheme.chatMessageBox.operatorMessage.voice.labelsTextSize = 14
        chatTheme.chatMessageBox.operatorMessage.voice.labelsTextColor = .black
        chatTheme.chatMessageBox.operatorMessage.voice.playBarColor = .white
        chatTheme.chatMessageBox.operatorMessage.voice.playedBarColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.beforeSendingPlayBarColor = .lightGray
        chatTheme.chatMessageBox.operatorMessage.voice.deleteButtonColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.operatorMessage.voice.bubbleColor = UIColor(netHex: 0xE1FDC7)
        chatTheme.chatMessageBox.operatorMessage.voice.bubbleImage = StandardImages.bubbleIncoming
        
        // Тема для иконки оператора в сообщении
        // Аватара
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.size = CGSize(width: 36, height: 36)
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.cornerRadius = 18
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.topIndent = 5
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.leftIndent = 8
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.avatar.rightIndent = 8
        
        // Имя
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.name.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.name.textColor = .black
        chatTheme.chatMessageBox.operatorMessage.operatorAccount.name.leftIndent = 0
        
        // Тема для установки отступа сообщения от краев экрана
        chatTheme.chatMessageBox.operatorMessage.messageIndent = MessageIndentTheme(trailing: 0, leading: 0)
        
        return chatTheme.chatMessageBox.operatorMessage
    }
    
    // MARK: - Тема для пользователя
    
    func getUserMessageTheme() -> MessageTheme {
        let chatTheme = ChatTheme()
        
        // Настройка расположения области даты относительно баббла сообщения
        chatTheme.chatMessageBox.userMessage.outgoingDateViewAlignment = .right
        
        // Тема для текстового сообщения
        chatTheme.chatMessageBox.userMessage.text.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.text.textColor = .white
        chatTheme.chatMessageBox.userMessage.text.dateColor = .black
        chatTheme.chatMessageBox.userMessage.text.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.text.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.text.padding = Padding(left: 8, top: 8, right: 14, bottom: 8)
        chatTheme.chatMessageBox.userMessage.text.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.text.outgoingLinkColor = .systemBlue
        
        // Тема для сообщения с файлом
        chatTheme.chatMessageBox.userMessage.file.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.file.textColor = .white
        chatTheme.chatMessageBox.userMessage.file.dateColor = .black
        chatTheme.chatMessageBox.userMessage.file.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.file.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.file.padding = Padding(left: 8, top: 8, right: 14, bottom: 8)
        chatTheme.chatMessageBox.userMessage.file.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.file.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.file.outgoingLinkColor = .systemBlue
        chatTheme.chatMessageBox.userMessage.file.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.file.icon = StandardImages.insertDriveFile
        chatTheme.chatMessageBox.userMessage.file.iconBackgroundColor = UIColor(netHex: 0xDCEFD6)
        chatTheme.chatMessageBox.userMessage.file.fileNameColor = UIColor(netHex: 0xF4F5F7)
        chatTheme.chatMessageBox.userMessage.file.fileSizeColor = UIColor(netHex: 0xB9DEAD)
        
        // Тема для сообщения с изображением
        chatTheme.chatMessageBox.userMessage.image.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.image.textColor = .white
        chatTheme.chatMessageBox.userMessage.image.dateColor = .black
        chatTheme.chatMessageBox.userMessage.image.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.image.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.image.padding = Padding(left: 8, top: 8, right: 14, bottom: 8)
        chatTheme.chatMessageBox.userMessage.image.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.image.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.image.outgoingLinkColor = .systemBlue
        chatTheme.chatMessageBox.userMessage.image.imageCornerRadius = 10
        chatTheme.chatMessageBox.userMessage.image.textPadding = Padding(left: 10, top: 10, right: 16, bottom: 10)
        chatTheme.chatMessageBox.userMessage.image.padding = Padding(left: 10, top: 10, right: 16, bottom: 10)
        
        // Тема для голосового сообщения
        chatTheme.chatMessageBox.userMessage.voice.font = UIFont.systemFont(ofSize: 14)
        chatTheme.chatMessageBox.userMessage.voice.textColor = .white
        chatTheme.chatMessageBox.userMessage.voice.dateColor = .black
        chatTheme.chatMessageBox.userMessage.voice.dateFont = UIFont.systemFont(ofSize: 12)
        chatTheme.chatMessageBox.userMessage.voice.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.backgroundImage = StandardImages.bubbleOutgoing
        chatTheme.chatMessageBox.userMessage.voice.messageStatusIndicator = getMessageStatusIndicatorTheme()
        chatTheme.chatMessageBox.userMessage.voice.outgoingLinkColor = .systemBlue
        chatTheme.chatMessageBox.userMessage.voice.playIcon = StandardImages.play
        chatTheme.chatMessageBox.userMessage.voice.pauseIcon = StandardImages.pause
        chatTheme.chatMessageBox.userMessage.voice.playIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.pauseIconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.buttonTopIndent = 13
        chatTheme.chatMessageBox.userMessage.voice.buttonLeftIndent = 5
        chatTheme.chatMessageBox.userMessage.voice.labelsTextSize = 14
        chatTheme.chatMessageBox.userMessage.voice.labelsTextColor = .black
        chatTheme.chatMessageBox.userMessage.voice.playBarColor = .white
        chatTheme.chatMessageBox.userMessage.voice.playedBarColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.beforeSendingPlayBarColor = .lightGray
        chatTheme.chatMessageBox.userMessage.voice.deleteButtonColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.voice.bubbleColor = UIColor(netHex: 0xE1FDC7)
        chatTheme.chatMessageBox.userMessage.voice.bubbleImage = StandardImages.bubbleOutgoing
        
        // Тема для установки отступа сообщения от краев экрана
        chatTheme.chatMessageBox.userMessage.messageIndent = MessageIndentTheme(trailing: 0, leading: 0)
        
        return chatTheme.chatMessageBox.userMessage
    }
    
    // MARK: - Тема для статуса сообщения
    
    func getMessageStatusIndicatorTheme() -> MessageStatusIndicatorTheme {
        let chatTheme = ChatTheme()
        
        // Тема для статуса "Доставляется"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.image = StandardImages.unsentClock
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.size = CGSize(width: 12, height: 12)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.tintColor = .lightGray
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveringIcon.altTintColor = .black
        
        // Тема для статуса "Доставлено"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.image = StandardImages.delivered
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.size = CGSize(width: 15, height: 15)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.tintColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.deliveredIcon.altTintColor = .black
        
        // Тема для статуса "Прочитано"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.image = StandardImages.read
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.size = CGSize(width: 15, height: 15)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.tintColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.readIcon.altTintColor = .black
        
        // Тема для статуса "Ошибка"
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.image = StandardImages.unsentError
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.size = CGSize(width: 15, height: 15)
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.tintColor = .red
        chatTheme.chatMessageBox.userMessage.text.messageStatusIndicator.failedIcon.altTintColor = .red
        
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
    
    // MARK: - Тема для сообщения с кнопками
    
    func getMessageButtonTheme() -> MessageButtonTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.messageButton.backgroundColor = UIColor(netHex: 0x343533)
        chatTheme.chatMessageBox.messageButton.backgroundColorPressed = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.messageButton.textColor = UIColor(netHex: 0xF5F6F8)
        chatTheme.chatMessageBox.messageButton.textColorPressed = .black
        chatTheme.chatMessageBox.messageButton.borderColor = .black
        chatTheme.chatMessageBox.messageButton.borderRadius = 8
        chatTheme.chatMessageBox.messageButton.borderColorPressed = UIColor(netHex: 0x47942a)
        chatTheme.chatMessageBox.messageButton.font = .systemFont(ofSize: 14)
        
        return chatTheme.chatMessageBox.messageButton
    }
    
    // MARK: - Тема для сообщения с кнопкой вызова выпадающего списка

    func getSelectorButtonTheme() -> SelectorButtonTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.selectorButton.textColor = .black
        chatTheme.chatMessageBox.selectorButton.tintColor = .gray
        chatTheme.chatMessageBox.selectorButton.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.selectorButton.incomingDateViewAlignment = .right
        chatTheme.chatMessageBox.selectorButton.outgoingDateViewAlignment = .right
        
        return chatTheme.chatMessageBox.selectorButton
    }
    
    // MARK: - Тема для системного сообщения

    func getSystemMessageTheme() -> SystemMessageTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.systemMessage.backgroundColor = UIColor(red: 81, green: 82, blue: 82)
        chatTheme.chatMessageBox.systemMessage.backgroundRadius = 8
        chatTheme.chatMessageBox.systemMessage.textColor = .white
        chatTheme.chatMessageBox.systemMessage.font = nil
        chatTheme.chatMessageBox.systemMessage.textAlignment = .center
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
        chatTheme.chatMessageBox.inlinePrechat.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.inlinePrechat.textColor = .black
        chatTheme.chatMessageBox.inlinePrechat.textAlignment = .left
        chatTheme.chatMessageBox.inlinePrechat.viewAlignment = .left
        chatTheme.chatMessageBox.inlinePrechat.backgroundColor = .white
        chatTheme.chatMessageBox.inlinePrechat.cornerRadius = 15
        chatTheme.chatMessageBox.inlinePrechat.offset = 20
        
        return chatTheme.chatMessageBox.inlinePrechat
    }
    
    // MARK: - Тема для пречат-полей

    func getPrechatTheme() -> PrechatTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.backgroundColor = .white
        
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
        
        return chatTheme.chatMessageBox.prechat
    }
    
    // MARK: - Тема для заголовка пречат-полей

    func getPrechatTitleTheme() -> PrechatTitleTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.prechatTitle.font = .systemFont(ofSize: 18)
        chatTheme.chatMessageBox.prechat.prechatTitle.fontSize = nil
        chatTheme.chatMessageBox.prechat.prechatTitle.textColor = .gray
        chatTheme.chatMessageBox.prechat.prechatTitle.textAlignment = .center
        chatTheme.chatMessageBox.prechat.prechatTitle.backgroundColor = .white
        chatTheme.chatMessageBox.prechat.prechatTitle.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.prechatTitle.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        return chatTheme.chatMessageBox.prechat.prechatTitle
    }
    
    // MARK: - Тема для заголовка пречат-поля

    func getPrechatFieldTitleTheme() -> PrechatFieldTitleTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.fieldTitle.font = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.fieldTitle.fontSize = nil
        chatTheme.chatMessageBox.prechat.fieldTitle.textColor = .black
        chatTheme.chatMessageBox.prechat.fieldTitle.textAlignment = .left
        chatTheme.chatMessageBox.prechat.fieldTitle.backgroundColor = .clear
        chatTheme.chatMessageBox.prechat.fieldTitle.cornerRadius = 0
        chatTheme.chatMessageBox.prechat.fieldTitle.requiredColor = .red
        
        return chatTheme.chatMessageBox.prechat.fieldTitle
    }
    
    // MARK: - Тема для пречат-поля

    func getPrechatFieldTheme() -> PrechatFieldTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.field.font = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.field.fontSize = nil
        chatTheme.chatMessageBox.prechat.field.textColor = .black
        chatTheme.chatMessageBox.prechat.field.textAlignment = .left
        chatTheme.chatMessageBox.prechat.field.errorFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.field.errorFontSize = nil
        chatTheme.chatMessageBox.prechat.field.errorTextColor = .black
        chatTheme.chatMessageBox.prechat.field.errorBorderColor = UIColor.red.cgColor
        chatTheme.chatMessageBox.prechat.field.backgroundColor = .clear
        chatTheme.chatMessageBox.prechat.field.fieldHeight = 44
        chatTheme.chatMessageBox.prechat.field.cornerRadius = 8
        chatTheme.chatMessageBox.prechat.field.borderWidth = 0.5
        chatTheme.chatMessageBox.prechat.field.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        chatTheme.chatMessageBox.prechat.field.borderStyle = .roundedRect
        
        return chatTheme.chatMessageBox.prechat.field
    }
    
    // MARK: - Тема для поля вопроса

    func getPrechatQuestionFieldTheme() -> PrechatQuestionFieldTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.questionField.placeholderFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.questionField.placeholderTextColor = .lightGray
        chatTheme.chatMessageBox.prechat.questionField.font = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.questionField.fontSize = nil
        chatTheme.chatMessageBox.prechat.questionField.textColor = .black
        chatTheme.chatMessageBox.prechat.questionField.textAlignment = .left
        chatTheme.chatMessageBox.prechat.questionField.errorFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.questionField.errorFontSize = nil
        chatTheme.chatMessageBox.prechat.questionField.errorTextColor = .black
        chatTheme.chatMessageBox.prechat.questionField.errorBorderColor = UIColor.red.cgColor
        chatTheme.chatMessageBox.prechat.questionField.backgroundColor = .clear
        chatTheme.chatMessageBox.prechat.questionField.fieldHeight = 88
        chatTheme.chatMessageBox.prechat.questionField.cornerRadius = 8
        chatTheme.chatMessageBox.prechat.questionField.borderWidth = 0.5
        chatTheme.chatMessageBox.prechat.questionField.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        chatTheme.chatMessageBox.prechat.questionField.borderStyle = .roundedRect
        
        return chatTheme.chatMessageBox.prechat.questionField
    }
    
    // MARK: - Тема для сообщения об ошибке

    func getPrechatFieldErrorLabelTheme() -> PrechatFieldErrorLabelTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.errorLabel.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.prechat.errorLabel.fontSize = nil
        chatTheme.chatMessageBox.prechat.errorLabel.textColor = UIColor(netHex: 0xFF2600)
        chatTheme.chatMessageBox.prechat.errorLabel.textAlignment = .left
        
        return chatTheme.chatMessageBox.prechat.errorLabel
    }
    
    // MARK: - Тема для кнопки отправки пречат-полей

    func getPrechatSendButtonTheme() -> PrechatSendButtonTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.prechat.sendButton.font = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.prechat.sendButton.textColor = UIColor(netHex: 0xF5F6F8)
        chatTheme.chatMessageBox.prechat.sendButton.textAlignment = .center
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
        
        chatTheme.chatMessageBox.prechat.selector.cell.textFont = .systemFont(ofSize: 17)
        chatTheme.chatMessageBox.prechat.selector.cell.textFontSize = nil
        chatTheme.chatMessageBox.prechat.selector.cell.textColor = .black
        chatTheme.chatMessageBox.prechat.selector.cell.backgroundColor = .white
        chatTheme.chatMessageBox.prechat.selector.cell.selectedBackgroundColor = nil
        
        chatTheme.chatMessageBox.prechat.selector.searchField.backgroundColor = .white
        chatTheme.chatMessageBox.prechat.selector.searchField.inputFieldColor = UIColor(red: 0.46, green: 0.46, blue: 0.5, alpha: 0.12)
        chatTheme.chatMessageBox.prechat.selector.searchField.magnifierColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        chatTheme.chatMessageBox.prechat.selector.searchField.cursorColor = .systemBlue
        chatTheme.chatMessageBox.prechat.selector.searchField.clearButtonColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        chatTheme.chatMessageBox.prechat.selector.searchField.cancelButtonColor = .systemBlue
        chatTheme.chatMessageBox.prechat.selector.searchField.textFont = .preferredFont(forTextStyle: .body).withSize(17)
        chatTheme.chatMessageBox.prechat.selector.searchField.textColor = .black
        
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
        chatTheme.chatMessageBox.input.textView.fontColor = .black
        chatTheme.chatMessageBox.input.textView.placeholderFontColor = .gray
        chatTheme.chatMessageBox.input.textView.cursorColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.textView.borderColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.textView.borderWidth = 1
        chatTheme.chatMessageBox.input.textView.borderRadius = 20
        chatTheme.chatMessageBox.input.textView.backgroundColor = .white
        chatTheme.chatMessageBox.input.textView.height = 40
        chatTheme.chatMessageBox.input.textView.textInset = UIEdgeInsets(top: 10, left: 8, bottom: 6, right: 8)
        chatTheme.chatMessageBox.input.textView.padding = UIEdgeInsets(top: 10, left: 56, bottom: 10, right: 56)
        chatTheme.chatMessageBox.input.textView.minLeftPadding = 8
        
        return chatTheme.chatMessageBox.input.textView
    }
    
    // MARK: - Тема для кнпоки прикрепления вложения
    
    func getInputPanelAttachButtonTheme() -> InputTheme.AttachTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.attach.icon = StandardImages.attachIcon
        chatTheme.chatMessageBox.input.attach.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.attach.iconColorPressed = .black
        chatTheme.chatMessageBox.input.attach.backgroundColor = .white
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
        chatTheme.chatMessageBox.input.timer.fontColor = .black
        
        return chatTheme.chatMessageBox.input.timer
    }
    
    // MARK: - Тема для кнопки отмены голосового сообщения
    
    func getInputPanelCancelEntryButtonTheme() -> InputTheme.CancelEntryTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.cancelEntry.icon = StandardImages.cancelEntry
        chatTheme.chatMessageBox.input.cancelEntry.iconColor = .black
        chatTheme.chatMessageBox.input.cancelEntry.textFont = nil
        chatTheme.chatMessageBox.input.cancelEntry.textFontSize = 13
        chatTheme.chatMessageBox.input.cancelEntry.textColor = .black
        
        return chatTheme.chatMessageBox.input.cancelEntry
    }
    
    // MARK: - Тема для кнопки закрепления голосового сообщения
    
    func getInputPanelLockButtonTheme() -> InputTheme.LockTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.input.lock.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.input.lock.imageColor = .white
        chatTheme.chatMessageBox.input.lock.swipeDirectionImageColor = .white
        
        return chatTheme.chatMessageBox.input.lock
    }
    
    // MARK: - Тема для панели вложения
    
    func getAttachmentPanelTheme() -> AttachmentPanelTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.attachment.backgroundColor = .clear
        chatTheme.chatMessageBox.attachment.leftPadding = 12
        chatTheme.chatMessageBox.attachment.rightPadding = 12
        chatTheme.chatMessageBox.attachment.spacing = 12
        chatTheme.chatMessageBox.attachment.image.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.attachment.image.cornerRadius = 0
        chatTheme.chatMessageBox.attachment.title.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.attachment.title.textColor = .black
        chatTheme.chatMessageBox.attachment.dismissButton.backgroundColor = .clear
        chatTheme.chatMessageBox.attachment.dismissButton.icon = StandardImages.trash
        chatTheme.chatMessageBox.attachment.dismissButton.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.attachment.dismissButton.size = CGSize(width: 20, height: 20)
        chatTheme.chatMessageBox.attachment.dismissButton.cornerRadius = 0
        chatTheme.chatMessageBox.attachment.dismissButton.imageInset = .zero
        
        return chatTheme.chatMessageBox.attachment
    }
    
    // MARK: - Тема для кнопки начала нового диалога

    func getNewDialogTheme() -> NewDialogTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.newDialog.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.newDialog.textFont = nil
        chatTheme.chatMessageBox.newDialog.textColor = .white
        chatTheme.chatMessageBox.newDialog.edgeInsets = .zero
        chatTheme.chatMessageBox.newDialog.cornerRadius = 0
        
        return chatTheme.chatMessageBox.newDialog
    }
    
    // MARK: - Тема для сообщения "Оператор печатает..."
    
    func getAgentTypingStatusTheme() -> AgentTypingStatusTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.agentTypingStatus.fontColor = .systemGray
        chatTheme.chatMessageBox.agentTypingStatus.font = nil
        
        return chatTheme.chatMessageBox.agentTypingStatus
    }

    // MARK: - Тема для NavigationBar
    
    func getNavigationBarTheme() -> NavigationBarTheme {
        let chatTheme = ChatTheme()
        
        // На экране пречат-полей
        chatTheme.chatMessageBox.navigationBar.prechat.barTintColor = .white
        chatTheme.chatMessageBox.navigationBar.prechat.tintColor = .black
        chatTheme.chatMessageBox.navigationBar.prechat.titleFont = .systemFont(ofSize: 16)
        chatTheme.chatMessageBox.navigationBar.prechat.titleColor = .black
        
        // На экране селектора в пречат-полях
        chatTheme.chatMessageBox.navigationBar.prechatSelector.barTintColor = .white
        chatTheme.chatMessageBox.navigationBar.prechatSelector.tintColor = .black
        chatTheme.chatMessageBox.navigationBar.prechatSelector.titleFont = .systemFont(ofSize: 16)
        chatTheme.chatMessageBox.navigationBar.prechatSelector.titleColor = .black
        
        // На экране просмотра файла в чате
        chatTheme.chatMessageBox.navigationBar.chatFile.barTintColor = .white
        chatTheme.chatMessageBox.navigationBar.chatFile.tintColor = .black
        chatTheme.chatMessageBox.navigationBar.chatFile.titleFont = .systemFont(ofSize: 16)
        chatTheme.chatMessageBox.navigationBar.chatFile.titleColor = .black
        
        return chatTheme.chatMessageBox.navigationBar
    }
    
    // MARK: - Тема для отправки истории диалога на почту
    
    func getSendHistoryTheme() -> SendHistoryTheme {
        let chatTheme = ChatTheme()
        
        // Кнопка в NavigationBar
        chatTheme.chatMessageBox.sendHistory.navBarButton.backgroundColor = .clear
        chatTheme.chatMessageBox.sendHistory.navBarButton.image = StandardImages.sendHistory
        chatTheme.chatMessageBox.sendHistory.navBarButton.imageColor = .gray
        chatTheme.chatMessageBox.sendHistory.navBarButton.imageInset = .zero
        chatTheme.chatMessageBox.sendHistory.navBarButton.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.sendHistory.navBarButton.cornerRadius = 0
        
        // Панель
        chatTheme.chatMessageBox.sendHistory.panel.backgroundColor = .white
        chatTheme.chatMessageBox.sendHistory.panel.cornerRadius = 15
        chatTheme.chatMessageBox.sendHistory.panel.barColor = UIColor(netHex: 0xD2D5D9)
        
        // Поле ввода почты
        chatTheme.chatMessageBox.sendHistory.panel.emailView.backgroundColor = .white
        chatTheme.chatMessageBox.sendHistory.panel.emailView.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.sendHistory.panel.emailView.textColor = .black
        chatTheme.chatMessageBox.sendHistory.panel.emailView.borderColor = UIColor.gray.withAlphaComponent(0.3)
        chatTheme.chatMessageBox.sendHistory.panel.emailView.borderWidth = 0.5
        chatTheme.chatMessageBox.sendHistory.panel.emailView.cornerRadius = 8
        
        // Кнопка отправки
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.backgroundColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.tintColor = .white
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.font = .systemFont(ofSize: 16)
        chatTheme.chatMessageBox.sendHistory.panel.sendButton.cornerRadius = 25
        
        // Лоадер
        chatTheme.chatMessageBox.sendHistory.panel.loader.tintColor = UIColor(netHex: 0x52AE30)
        
        // Сообщение в случае ошибки
        chatTheme.chatMessageBox.sendHistory.panel.error.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.sendHistory.panel.error.textColor = UIColor(netHex: 0xFF2600)
        chatTheme.chatMessageBox.sendHistory.panel.error.textAlignment = .left
        
        // Сообщение в случае успеха
        chatTheme.chatMessageBox.sendHistory.panel.success.font = .systemFont(ofSize: 16)
        chatTheme.chatMessageBox.sendHistory.panel.success.textColor = .gray
        chatTheme.chatMessageBox.sendHistory.panel.success.textAlignment = .center
        
        return chatTheme.chatMessageBox.sendHistory
    }
    
    // MARK: - Тема для видеозвонка
    
    func getVideoCallTheme() -> VideoCallTheme {
        let chatTheme = ChatTheme()
        
        // Кнопка в NavigationBar
        chatTheme.chatMessageBox.videoCall.navBarButton.backgroundColor = .clear
        chatTheme.chatMessageBox.videoCall.navBarButton.image = StandardImages.videoCall
        chatTheme.chatMessageBox.videoCall.navBarButton.imageColor = .gray
        chatTheme.chatMessageBox.videoCall.navBarButton.imageInset = .zero
        chatTheme.chatMessageBox.videoCall.navBarButton.size = CGSize(width: 32, height: 32)
        chatTheme.chatMessageBox.videoCall.navBarButton.cornerRadius = 0
        
        return chatTheme.chatMessageBox.videoCall
    }

    // MARK: - Тема для кнопки оценки диалога
    
    func getRatingButtonTheme() -> ChatRatingTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.chatRating.needShowRateButton = true
        chatTheme.chatMessageBox.chatRating.rateButtonNormalColor = .gray
        chatTheme.chatMessageBox.chatRating.rateButtonRatedColor = UIColor(netHex: 0xF5A623)
        
        return chatTheme.chatMessageBox.chatRating
    }

    // MARK: - Тема для окна оценки диалога
    
    func getRatingScreenTheme() -> RatingScreenTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.ratingScreen.background = UIColor(netHex: 0xF0F0F8)
        
        // Кнопка подтверждения
        chatTheme.chatMessageBox.ratingScreen.submitButton.bgColor = UIColor(netHex: 0x50a82f)
        chatTheme.chatMessageBox.ratingScreen.submitButton.bgColorPressed = UIColor(netHex: 0x3e8423)
        chatTheme.chatMessageBox.ratingScreen.submitButton.bgColorDisabled = UIColor(netHex: 0x90c77b)
        chatTheme.chatMessageBox.ratingScreen.submitButton.textColor = UIColor(netHex: 0xffffff)
        chatTheme.chatMessageBox.ratingScreen.submitButton.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.ratingScreen.submitButton.padding = Padding(left: 0, top: 16, right: 0, bottom: 16)
        chatTheme.chatMessageBox.ratingScreen.submitButton.buttonBorderRadius = 16
        chatTheme.chatMessageBox.ratingScreen.submitButton.iconColor = nil
        chatTheme.chatMessageBox.ratingScreen.submitButton.iconColorPressed = nil
        chatTheme.chatMessageBox.ratingScreen.submitButton.iconColorDisabled = nil
        
        // Кнопка отмены
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.bgColor = UIColor(netHex: 0xffffff)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.bgColorPressed = UIColor(netHex: 0xe2e2e2)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.bgColorDisabled = UIColor(netHex: 0xffffff)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.textColor = UIColor(netHex: 0x50a82f)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.font = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.padding = Padding(left: 0, top: 16, right: 0, bottom: 16)
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.buttonBorderRadius = 16
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.iconColor = nil
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.iconColorPressed = nil
        chatTheme.chatMessageBox.ratingScreen.nextTimeButton.iconColorDisabled = nil
        
        // Текст
        chatTheme.chatMessageBox.ratingScreen.text.font = .systemFont(ofSize: 25)
        chatTheme.chatMessageBox.ratingScreen.text.color = .black
        
        // Подсказка
        chatTheme.chatMessageBox.ratingScreen.tooltip.font = UIFont(name: "Futura-Medium", size: 13)
        chatTheme.chatMessageBox.ratingScreen.tooltip.backgroundColor = .white
        chatTheme.chatMessageBox.ratingScreen.tooltip.textColor = .black
        chatTheme.chatMessageBox.ratingScreen.tooltip.borderColor = nil
        chatTheme.chatMessageBox.ratingScreen.tooltip.borderWidth = nil
        chatTheme.chatMessageBox.ratingScreen.tooltip.verticalInset = 25
        chatTheme.chatMessageBox.ratingScreen.tooltip.horizontalInset = 25
        
        // Тема для звездочек
        chatTheme.chatMessageBox.ratingScreen.stars.colorFilled = UIColor(netHex: 0xFFE025)
        chatTheme.chatMessageBox.ratingScreen.stars.borderWidthFilled = 2
        chatTheme.chatMessageBox.ratingScreen.stars.borderColorFilled = UIColor(netHex: 0xFFE025)
        chatTheme.chatMessageBox.ratingScreen.stars.colorEmpty = .white
        chatTheme.chatMessageBox.ratingScreen.stars.borderColorEmpty = UIColor(netHex: 0x686B70)
        chatTheme.chatMessageBox.ratingScreen.stars.borderWidthEmpty = 2
        chatTheme.chatMessageBox.ratingScreen.stars.starSize = 32
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
        chatTheme.chatMessageBox.rateResponse.stars.colorEmpty = .white
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
        
        chatTheme.chatMessageBox.autocomplete.backgroundColor = .white
        chatTheme.chatMessageBox.autocomplete.textColor = .black
        chatTheme.chatMessageBox.autocomplete.borderColor = .lightGray
        chatTheme.chatMessageBox.autocomplete.padding = Padding(left: 8, top: 8, right: 8, bottom: 8)
        chatTheme.chatMessageBox.autocomplete.textAlignment = .center
        chatTheme.chatMessageBox.autocomplete.fontSize = nil
        chatTheme.chatMessageBox.autocomplete.font = nil
        
        return chatTheme.chatMessageBox.autocomplete
    }
    
    // MARK: - Тема для отображаемой ошибки (кроме экрана чата)
    
    func getErrorTheme() -> ChatErrorTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.error.backgroundColor = .white
        chatTheme.chatMessageBox.error.cornerRadius = 15
        chatTheme.chatMessageBox.error.textFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.error.textColor = .black
        chatTheme.chatMessageBox.error.textAlignment = .natural
        chatTheme.chatMessageBox.error.textPadding = nil
        chatTheme.chatMessageBox.error.bubbleMargin = nil
        chatTheme.chatMessageBox.error.needShadow = true
        
        return chatTheme.chatMessageBox.error
    }
    
    // MARK: - Тема для отображаемой ошибки на экране чата
    
    func getChatErrorTheme() -> ChatErrorTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.chatError.backgroundColor = .white
        chatTheme.chatMessageBox.chatError.cornerRadius = 15
        chatTheme.chatMessageBox.chatError.textFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.chatError.textColor = .black
        chatTheme.chatMessageBox.chatError.textAlignment = .natural
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
        chatTheme.chatMessageBox.chatDate.textColor = .lightGray
        chatTheme.chatMessageBox.chatDate.isUppercased = false
        chatTheme.chatMessageBox.chatDate.padding = Padding(left: 8, top: 8, right: 8, bottom: 8)
        
        return chatTheme.chatMessageBox.chatDate
    }
    
    // MARK: - Тема для контроллера выбора типа вложения
    
    func getAttachPopupControllerTheme() -> AttachPopupTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.popupControllerStyle.iconColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.popupControllerStyle.font = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.popupControllerStyle.textColor = .darkGray
        chatTheme.chatMessageBox.popupControllerStyle.cancelFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.popupControllerStyle.cancelColor = .darkGray
        chatTheme.chatMessageBox.popupControllerStyle.contentInset.left = 20
        chatTheme.chatMessageBox.popupControllerStyle.contentInset.right = 20
        chatTheme.chatMessageBox.popupControllerStyle.contentInset.bottom = 20
        
        return chatTheme.chatMessageBox.popupControllerStyle
    }
    
    // MARK: - Тема для сообщения о том, что витрина оффлайн
    
    func getOfflineMessageTheme() -> OfflineMessageTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.offlineMessage.textColor = .lightGray
        chatTheme.chatMessageBox.offlineMessage.textFont = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.offlineMessage.textAlignment = .center
        chatTheme.chatMessageBox.offlineMessage.backgroundColor = .clear
        chatTheme.chatMessageBox.offlineMessage.cornerRadius = 0
        chatTheme.chatMessageBox.offlineMessage.padding = Padding(left: 16, top: 12, right: 16, bottom: 12)
        chatTheme.chatMessageBox.offlineMessage.textInset = Padding(left: 0, top: 0, right: 0, bottom: 0)
        
        return chatTheme.chatMessageBox.offlineMessage
    }
    
    // MARK: - Тема для сообщения о том, что витрина заблокирована
    
    func getShowcaseBlockedPanelTheme() -> ShowcaseBlockedPanelTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.showcaseBlockedPanel.textColor = UIColor(netHex: 0x777C87)
        chatTheme.chatMessageBox.showcaseBlockedPanel.textFont = .systemFont(ofSize: 14)
        chatTheme.chatMessageBox.showcaseBlockedPanel.textAlignment = .center
        chatTheme.chatMessageBox.showcaseBlockedPanel.image = StandardImages.showcaseBlocked
        chatTheme.chatMessageBox.showcaseBlockedPanel.imageColor = UIColor(netHex: 0x95909E).withAlphaComponent(0.5)
        chatTheme.chatMessageBox.showcaseBlockedPanel.backgroundColor = UIColor(netHex: 0xF5F6F8)
        chatTheme.chatMessageBox.showcaseBlockedPanel.textInset = Padding(left: 0, top: 0, right: 0, bottom: 0)
        
        return chatTheme.chatMessageBox.showcaseBlockedPanel
    }
    
    // MARK: - Тема для поля опросника
    
    func getQuestionaryFieldTheme() -> QuestionaryFieldTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.questionaryField.tintColor = UIColor(netHex: 0x777C87)
        chatTheme.chatMessageBox.questionaryField.height = 46
        chatTheme.chatMessageBox.questionaryField.textColor = .black
        chatTheme.chatMessageBox.questionaryField.textFont = .systemFont(ofSize: 16, weight: .regular)
        chatTheme.chatMessageBox.questionaryField.errorTextColor = .red
        chatTheme.chatMessageBox.questionaryField.errorTextFont = .systemFont(ofSize: 12)
        
        return chatTheme.chatMessageBox.questionaryField
    }
    
    // MARK: - Тема для окна благодарности за прохождение опроса
    
    func getQuestionaryGratitudeScreenTheme() -> QuestionaryGratitudeScreenTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.thanksTextFont = .systemFont(ofSize: 20, weight: .bold)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.messageTextFont = .systemFont(ofSize: 16, weight: .regular)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.thanksTextColor = UIColor(netHex: 0x222B55)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.messageTextColor = UIColor(netHex: 0x222B55)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonDefaultColor = UIColor(netHex: 0x52AE30)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonTappedColor = UIColor(netHex: 0x52AE30).withAlphaComponent(0.8)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonInactiveColor = UIColor(netHex: 0x52AE30).withAlphaComponent(0.4)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonTitleColor = .white
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonTitleFont = .systemFont(ofSize: 16, weight: .regular)
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonTitlePadding = 12
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonCornerRadius = 43 / 2
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.closeButtonTitle = "Закрыть"
        chatTheme.chatMessageBox.questionaryGratitudeScreenTheme.messageText = "Мы учтём ваши ответы и сделаем сервис ещё лучше!"
        
        return chatTheme.chatMessageBox.questionaryGratitudeScreenTheme
    }
    
    // MARK: - Тема для кнопки прокрутки истории диалога
    
    func getScrollDownArrowTheme() -> ScrollDownArrowTheme {
        let chatTheme = ChatTheme()
        
        chatTheme.chatMessageBox.scrollDownArrow.image = StandardImages.arrowDown
        chatTheme.chatMessageBox.scrollDownArrow.imageColor = UIColor(netHex: 0xCCCCCC)
        chatTheme.chatMessageBox.scrollDownArrow.backgroundColor = .white
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
        chatTheme.chatMessageBox.contextMenu.messageCopied.backgroundColor = .black.withAlphaComponent(0.8)
        chatTheme.chatMessageBox.contextMenu.messageCopied.cornerRadius = 15
        chatTheme.chatMessageBox.contextMenu.messageCopied.textFont = .systemFont(ofSize: 15)
        chatTheme.chatMessageBox.contextMenu.messageCopied.textColor = .white
        chatTheme.chatMessageBox.contextMenu.messageCopied.textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        chatTheme.chatMessageBox.contextMenu.messageCopied.bubbleMargin = nil
        
        return chatTheme.chatMessageBox.contextMenu
    }
    
}

