

const copyToClipboard = () => {
  const copyBtns = document.querySelectorAll('.fas.fa-copy');
  console.log(copyBtns)

  copyBtns.forEach(elem => {
    let command = elem.dataset.target
    console.log(elem.dataset.target)

    let commadToCpy = document.querySelector(`#${command}`);
    //console.log("hhheey", commadToCpy.value)

    elem.addEventListener('click', (event) => {
      commadToCpy.select()
      commadToCpy.style = "color: #6C72FA; outline: none;"
      document.execCommand("copy")
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
