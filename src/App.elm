module App exposing (subscriptions)

import Draggable

import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports

subscriptionsDraggable : Model -> Sub Msg
subscriptionsDraggable { drag } = 
    Draggable.subscriptions DragMsg drag

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [
                subscriptionsLocalStorage model,
                subscriptionsDraggable model,
                subscriptionsSvgDownload model]

------- Local Stroage --------------------------------
subscriptionsLocalStorage : Model -> Sub Msg
subscriptionsLocalStorage _ = 
        Ports.receiveData ReceivedDataFromJS    

subscriptionsSvgDownload : Model -> Sub Msg
subscriptionsSvgDownload _ = 
          Ports.gotSvg GotSvg   