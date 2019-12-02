const deviseLink = () => {
  const deviseCheckbox = document.querySelector('#devise_checkbox');
  const codeInputCommand = document.querySelector('#code-input-command');
  const showHide = document.querySelector('#show_hide_devise_span');
  const originalCodeCommand = codeInputCommand.value;

  deviseCheckbox.addEventListener('change', event => {
    let codeCommand = codeInputCommand.value;
    showHide.classList.toggle("devise-hidden")
    if (deviseCheckbox.checked) {
      const deviseDropdownSelect = document.querySelector('#devise-dropdown-select');
      let codeCommand = codeInputCommand.value;
      let deviseModel = deviseDropdownSelect.value;
      const regex = /(\/templat[^\s]+)/
      let match = codeCommand.match(regex)
      codeInputCommand.value = codeCommand.replace(regex, `/template/devise/${deviseModel}`);
      deviseDropdownSelect.addEventListener('change', event => {
        let deviseModel = deviseDropdownSelect.value;
        codeInputCommand.value = codeCommand.replace(regex, `/template/devise/${deviseModel}`);
      });
    } else {
      codeInputCommand.value = originalCodeCommand
    }
  });
}


// const githubLink = () => {
//   const githubCheckbox = document.querySelector('#github_checkbox');
//   const codeInputCommand = document.querySelector('#code-input-command');
//   const originalCodeCommand = codeInputCommand.value;

//   githubCheckbox.addEventListener('change', event => {
//     let codeCommand = codeInputCommand.value;
//     if (githubCheckbox.checked) {
//       let codeCommand = codeInputCommand.value;
//       const regex = /(\/templat[^\s]+)/
//       let match = codeCommand.match(regex)
//       codeInputCommand.value = codeCommand.replace(regex, `/template-github`);
//     } else {
//       codeInputCommand.value = originalCodeCommand
//     }
//   });
// }




export { deviseLink }
export { githubLink }
