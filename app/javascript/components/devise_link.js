const deviseLink = () => {
  const deviseCheckbox = document.querySelector('#devise_checkbox');
  const codeInputCommand = document.querySelector('#code-input-command');
  const showHide = document.querySelector('#show_hide_devise_span');
  const originalCodeCommand = codeInputCommand.value;

  deviseCheckbox.addEventListener('change', event => {
    let codeCommand = codeInputCommand.value;
    showHide.classList.toggle("devise-hidden")
    if (deviseCheckbox.checked) {
      // const deviseDropdownSelect = document.querySelector('#devise-dropdown-select');
      let codeCommand = codeInputCommand.value;
      // let deviseModel = deviseDropdownSelect.value;
      const regex = /(\/templat[^\s]+)/
      let match = codeCommand.match(regex)
      codeInputCommand.value = codeCommand.replace(regex, `/template/devise`);
      // deviseDropdownSelect.addEventListener('change', event => {
      //   let deviseModel = deviseDropdownSelect.value;
      //   codeInputCommand.value = codeCommand.replace(regex, `/template/devise`);
      // });
    } else {
      codeInputCommand.value = originalCodeCommand
    }
  });
}

// const githubLink = () => {
//   const githubCheckbox = document.querySelector('#github_checkbox');
//   const codeInputCommand = document.querySelector('#code-input-command');
//   const originalCodeCommand = codeInputCommand.value;
//   const allCheckBoxes

//   array.delete(elem.dataset.target)


//   allCheckBoxes.forEach(box...
//     box.addEventListener...)

//   githubCheckbox.addEventListener('change', event => {
//     let codeCommand = codeInputCommand.value;
//     if (githubCheckbox.checked) {
//       let codeCommand = codeInputCommand.value;
//       const regex = /(\/templat[^\s]+)/
//       let match = codeCommand.match(regex)
//       codeInputCommand.value = codeCommand.replace(regex, `/template/${array.join("")}`);
//     } else {
//       codeInputCommand.value = originalCodeCommand
//     }
//   });
// }


const checkBoxes = () => {
  let checkBoxArray = [];

  const allCheckBoxes = document.querySelectorAll('.wald-checkbox');
  const codeInputCommand = document.querySelector('#code-input-command');
  const originalCodeCommand = codeInputCommand.value;

  allCheckBoxes.forEach (box => {
    let checked = box.dataset.target;
    box.addEventListener ('change', (event) => {
      if(document.querySelector(`#${checked.substr(1)}_show_hide_span`)) {
        document.querySelector(`#${checked.substr(1)}_show_hide_span`).classList.toggle("devise-hidden")
      }
      if (box.checked) {
        checkBoxArray.push(checked);
        console.log(checkBoxArray);
        let codeCommand = codeInputCommand.value;
        const regex = /(\/templat[^\s]+)/
        let match = codeCommand.match(regex)
        codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
      }
      else {
        let index = checkBoxArray.indexOf(checked)
        checkBoxArray.splice(index, 1)
        let codeCommand = codeInputCommand.value;
        const regex = /(\/templat[^\s]+)/
        let match = codeCommand.match(regex)
        codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
        console.log(checkBoxArray);
      }
    });
  });
}



// export { githubCheckbox }
// export { deviseLink }
// export { githubLink }


const alertsInfo = () => {
  const herokuBox = document.querySelector('#heroku_checkbox');
  const deviseBox = document.querySelector('#devise_checkbox');

  let herokuAlerted = false;
  let deviseAlerted = false;

  herokuBox.addEventListener("click", (event) => {
    if (herokuAlerted === false) {
      swal('You must install and log-in to Heroku before starting! \n App name must be unique! Heroku will raise an error if not.');
      herokuAlerted = true;
    }
  });

  deviseBox.addEventListener("click", (event) => {
    if (deviseAlerted === false) {
      swal('\'Devise\' require \'user\' table, therefore if you don\'t have one we will create it for you!');
      deviseAlerted = true;
    }
  });
}


export { alertsInfo }
export { checkBoxes }
