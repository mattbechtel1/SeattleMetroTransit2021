// const baseUrl = 'https://dc-metrobus-2020-api.herokuapp.com'
const baseUrl = 'http://localhost:3000'
const favoriteUrl = `${baseUrl}/favorites`

if (navigator.appName == 'Microsoft Internet Explorer' ||  !!(navigator.userAgent.match(/Trident/) || navigator.userAgent.match(/rv:11/)) || (typeof $.browser !== "undefined" && $.browser.msie == 1))
{
  alert("MetroBus 2020 utilizes technology that is not currently compatible with Internet Explorer. Please consider switching to a modern browser.");
}

const hostedObj = function(requestType, formResponseObj) {
  return {
    method: requestType,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify(formResponseObj)
  }
}

function clearAndReturnMain() {
  let mainContainer = document.getElementById('main-container')
  mainContainer.innerHTML = ""
  return mainContainer
}

function addFavorite(e) {
  if (!userHeldInState) {
    errorNotification('Please log in to declare favorites')

  } else {

    let stopId = e.target.dataset.stop;
    let defaultDescription = e.target.dataset.description
    
    let postObj = {
      'lookup': stopId,
      'user_id': userHeldInState.id,
      'description': defaultDescription,
      'transit_type': e.target.dataset.stopType,
      'permanent_desc': defaultDescription
    }

    loaderNotification('Adding to your favorites list...')
    
    fetch(favoriteUrl, hostedObj('POST', postObj))
    .then(response => response.json())
    .then(newFav => {
      userHeldInState.favorites.push(newFav)
      confirmNotification(`${newFav.description} has been added to your favorites.`)
    })
    .catch(displayError)
  }
}