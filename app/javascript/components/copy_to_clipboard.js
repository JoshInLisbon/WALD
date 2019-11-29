

const copyToClipboard = () => {
  const copyBtns = document.querySelectorAll('.fas.fa-copy');

  copyBtns.forEach(elem => {
    let command = elem.dataset.target

    let commadToCpy = document.querySelector(`#${command}`);
    //console.log("hhheey", commadToCpy.value)

    elem.addEventListener('click', (event) => {
      // console.log(elem.dataset.target)
      if (elem.dataset.target === "code-input-link") {
        // console.log(document.querySelector('#code-input-link').innerText)
        commadToCpy.select()
        let width = commadToCpy.value.length * 9;
        commadToCpy.style = `width: ${width}px; color: #6C72FA; outline: none;`
        document.execCommand("copy")
      } else {
        commadToCpy.select()
        commadToCpy.style = "color: #6C72FA; outline: none;"
        document.execCommand("copy")
      }
    });

  })

}

export { copyToClipboard }


// const copyToClipboard = () => {
//   document.addEventListener('click', (event) => {
//     console.log(event.currentTarget);
//   })

// };

// export { copyToClipboard }
// let textarea = document.getElementById("textarea");
//   textarea.select();
//   document.execCommand("copy");
