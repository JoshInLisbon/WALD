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
        let codeCommand = codeInputCommand.value;
        const regex = /(\/templat[^\s]+)/
        let match = codeCommand.match(regex)
        codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
        if (checked == '&devise') {
          if(document.querySelector(`[data-target="&s-user"]`)) {
            document.querySelector(`[data-color="&s-user"]`).style = "display: none;";
            document.querySelector('[data-color="&s-user"]').classList.remove("s-color-selected");
            document.querySelector('[data-target="&s-user"]').classList.remove("scaffold-checkbox");
            document.querySelector('[data-target="&s-user"]').checked = false;
            if(checkBoxArray.includes('&s-user')) {
              let index = checkBoxArray.indexOf('&s-user');
              checkBoxArray.splice(index, 1);
              let match = codeCommand.match(regex);
              codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
            }
          }
        }
        if (checked == '&s-all') {
          document.querySelector(`[data-color="&s-all"]`).classList.toggle("s-all-color-selected");
          const allScaffoldCheckBoxes = document.querySelectorAll('.scaffold-checkbox');
          let index = checkBoxArray.indexOf(checked)
          checkBoxArray.splice(index, 1)
          allScaffoldCheckBoxes.forEach ((sBox, i) => {
              setTimeout(() => {
                sBox.checked = true;
                document.querySelector(`[data-color="${sBox.dataset.target}"]`).className += " s-color-selected";
                checkBoxArray.push(sBox.dataset.target);
                let match = codeCommand.match(regex)
                codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
              }, 50 + (i * (50)))
          });
        }
        if (document.querySelector(`[data-color="${box.dataset.target}"]`)) {
          document.querySelector(`[data-color="${box.dataset.target}"]`).classList.toggle("s-color-selected");
        }

      }
      else {
        let index = checkBoxArray.indexOf(checked)
        if (index > 0) {
          checkBoxArray.splice(index, 1)
        }
        let codeCommand = codeInputCommand.value;
        const regex = /(\/templat[^\s]+)/
        let match = codeCommand.match(regex)
        codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
        if (checked == '&devise') {
          console.log("hello");
          if(document.querySelector(`[data-target="&s-user"]`)) {
            document.querySelector(`[data-color="&s-user"]`).style = "display: inline-block;";
            document.querySelector('[data-target="&s-user"]').className += " scaffold-checkbox";
          }
          let index = checkBoxArray.indexOf(checked)
          console.log(index);
          if (index >= 0) {
            checkBoxArray.splice(index, 1)
            let match = codeCommand.match(regex)
            codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
          }
          // let codeCommand = codeInputCommand.value;
          // const regex = /(\/templat[^\s]+)/
          // let match = codeCommand.match(regex)
          // codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
        }
        if (checked == '&s-all') {
          document.querySelector(`[data-color="&s-all"]`).classList.toggle("s-all-color-selected");
          const allScaffoldCheckBoxes = document.querySelectorAll('.scaffold-checkbox');
          console.log(allScaffoldCheckBoxes);
          allScaffoldCheckBoxes.forEach ((sBox, i) => {
              setTimeout(() => {
                sBox.checked = false;
                document.querySelector(`[data-color="${sBox.dataset.target}"]`).classList.remove("s-color-selected");
                let index = checkBoxArray.indexOf(sBox.dataset.target)
                console.log(checkBoxArray.indexOf(sBox.dataset.target))
                console.log(sBox.dataset.target);
                if (index >= 0) {
                  checkBoxArray.splice(index, 1)
                  let match = codeCommand.match(regex)
                  console.log(checkBoxArray);
                  codeInputCommand.value = codeCommand.replace(regex, `/template/${checkBoxArray.join("")}`);
                }
              }, 50 + (i * (50)))
          });
        }
        if (document.querySelector(`[data-color="${box.dataset.target}"]`)) {
          document.querySelector(`[data-color="${box.dataset.target}"]`).classList.toggle("s-color-selected");
        }
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
