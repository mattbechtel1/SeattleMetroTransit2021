// const baseUrl = 'https://dc-metrobus-2020-api.herokuapp.com'

const ua = window.navigator.userAgent
if (!!ua.match(/Trident/) || !!ua.match(/Edge/) || !!ua.match(/MSIE/)) {
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


let baseUrl = 'http://localhost:3000'

const dcUrl = 'https://dc-metrobus-2020-api.herokuapp.com'
const seattleUrl = 'http://localhost:3000'

function changeBaseUrl(city) {
  switch(city) {
      case 'seattle':
          baseUrl = seattleUrl
      case 'washington':
          baseUrl = dcUrl
  }
}

function changeCityName(city) {
  function getCityName(city) {
    switch(city) {
      case 'seattle':
        return "Seattle"
      case 'washington':
        return "DC"
    }
  }

  document.getElementById("app_header").innerText = getCityName(city) + " Metrobus App"
}

function changeCity(city) {
  changeBaseUrl(city)
  changeCityName(city)
}