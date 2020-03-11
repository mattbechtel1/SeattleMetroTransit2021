const baseUrl = 'https://dc-metrobus-2020-api.herokuapp.com'
// const baseUrl = 'http://localhost:3000'

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