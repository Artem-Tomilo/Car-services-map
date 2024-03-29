# Car service places
### UIKit app for finding car service locations
Основной испльзуемый стек: UIKit, Navigation Controller, Google (Maps, Places, Direction, Distance), Firebase (Auth, Realtime Database, Storage), Alert Controller, JSON,Alamofire. 

Краткое описание: отображение на карте внесенных в базу данных мест обслуживания автомобилей, их сортировка по услугам, прокладывание маршрута, возможность добавления этиx мест в избранное, а также личный кабинет с информацией о пользователе. 

1) Проект написан на UIKit. 
2) Были использованы Navigation Controller, Collection View, Table View, кастомные ячейки, xib-файлы. 
3) Возможность загрузки фотографии из галереи для установки на аватар в личном кабинете пользователя. 
4) Регистрация через Firebase Authentication, места хранятся в Firebase Realtime database, фотографии пользователя в Firebase storage.
5) Используются Google Maps с доп. функциями гугла (места, расстояние и маршруты). 

Что планируется добавить:
1) Первоочередное - добавление архитектуры. 
2) Добавление дополнительных функций и усовершествование приложиния. 
3) Рефакторинг кода, а также мелкие доработки. 
___

### Начальный экран
#### Начальный экран представляет собой экран входа, а также кнопки с переходом на экран регистрации, экран восстановления пароля или входа по Google-аккаунту:
<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/1.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/2.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/3.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/4.png" width="300">
___

### Отображение карты
#### После ввода логина и пароля и запроса о текущем местоположение, карта отобразится на пользователе, а также покажет места в радиусе 7км. При нажатии на кнопку троеточия откроются кнопки с дополнительными возможностями отображения:
<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/5.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/8.png" width="300">

Этими кнопками можно регулировать зум карты, получать актуальную информацию по пробкам, переместить карту на текущее местополжения пользователя, а также менять стиль карты (темный/светлый). При нажатии на кнопку с флажком будут отображены все добавленные в приложение места. Повторное нажатие снова отобразит места только в радиусе 7км.

<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/10.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/11.png" width="300">

Также можно воспользоваться поиском по Google Places и если такое место присутствует, то карта переместиться с акцентом на него и покажет информационное меню, в котором кроме актуальной информации есть кнопки перехода на сайт компании, звонка на указанный номер и кнопка прокладывания маршрута:

<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/21.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/22.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/23.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/24.png" width="300">
___

### Фильтр
#### При нажатии на кнопку фильтра открывается экран с возможностью сортировки мест по их актуальным услугам. Кнопка "Accept" подтверждает выбор, "Reset all" сбрасывает все выбранные услуги:
<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/7.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/9.png" width="300">
___

### Боковое меню
#### При нажатии на кнопку меню, отображается боковое меню с возможностью перехода в личный аккаунт, избранные места и тд. Также присутствует кнопка выхода из аккаунта:
<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/12.png" width="300">

#### Избранные места отображаются списком, на каждое можно нажать и получить доступную информацию:
<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/14.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/15.png" width="300">

#### При входе в личный кабинет отображается информация о пользователе и тут же есть возможность ее изменить, нажав на кнопку карандаша справа вверху:
<img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/18.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/19.png" width="300"> <img src="https://github.com/Umbr0o/Diplom-project/blob/main/Diplom-project/Screens/20.png" width="300">
