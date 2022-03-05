# Stocks
Stocks - это приложение, где вы в два клика можете посмореть актуальную информацию о любой акции.
<img src="https://user-images.githubusercontent.com/99677952/153943249-8acc3174-d6d1-4bfd-ba62-a7a3cd6e52d6.png" width="300" /> <img src="https://user-images.githubusercontent.com/99677952/153943547-ce58a666-0f50-4599-8247-6ac493e89dea.png" width="300" /> <img src="https://user-images.githubusercontent.com/99677952/156874965-f1361674-45d9-4076-af10-3954825a1869.png" width="300" /> 


Приложение встречает нас SearchBar'ом и вьюшкой с подсказкой, что нужно делать (которая исчезает, когда вызывается метод willPresentSearchController). 
Пользователь может ввести фрагмент тиккера или названия компания, после чего появляется TableView с результатом поиска. Я ввел таймер на отправление запроса на сервер, чтобы пользователь успел ввести текст.
При тапе на ячейку появляется следующая вьюшка с лого компанией, ее названием, тиккером, актуальной ценой акции, валютой и изменением в процентах.

Так как iexcloud.io предоставляет поиск по фрагменту исключительно по подписке, я использовал для поиска другой апи: https://www.alphavantage.co.
Он позволяет делать только 5 запросов в минуту, поэтому я создал несколько ключей, чтобы минимизировать вероятность ошибки. Как итог tableView передает тиккер следующей вьюшке, которая уже отправляет запрос на получение детальной информации и лого.
Также база этих двух API отличается, поэтому по некоторым тиккерам нельзя получить информацию (в данном случае алерт сообщает пользователю об ошибке). Такова реальность халявщиков.

Для того чтобы получить и логотип, и дополнительную информацию о тиккере, нужно отправлять два разных запроса. Здесь и зарылась собака. Пришлось использовать DispatchGroup, чтобы картинка и текст появлялись на экране одновременно.

# План развития
У меня есть несколько идей, которые я не успел, но хотел бы реализовать
* Перевод приложения на MVP.
Уже можно заметить, сколько задач лежит на контроллере, поэтому архитектуру надо менять.
* График изменения цен.
К сожалению, мне немного не хватило времени, чтобы реализовать этот график, он бы отлично дополнил цель приложения. Но для себя я доделаю эту фичу, тем более мне осталось совсем немного работы.
* Финансовый калькулятор.
Можно позволить пользователю выбрать избранные акции и отслеживать сколько он заработал, предворительно введя количество купленных акций и потраченную сумму.


