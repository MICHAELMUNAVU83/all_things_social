// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

let Hooks = {};

Hooks.Testimonials = {
  mounted() {
    const testimonials = [
      {
        content:
          "All Things Social has completely transformed the way I manage my influencer collaborations. Their platform is intuitive, efficient, and streamlines the entire process from finding the right brands to tracking campaign performance. It's like having a personal assistant for influencer marketing!",
        name: "Linda Mwende",
        title: "Influencer",
        stars: "/images/4stars.png",
        image: "/images/testimonialuser2.jpeg",
      },
      {
        content:
          "Partnering with influencers has been a cornerstone of our marketing strategy, and All Things Social has become an indispensable asset in that regard. The platform's comprehensive database helped us discover the perfect influencers for our niche, and the integrated campaign management tools made the entire process seamless. Our ROI on influencer campaigns has significantly improved since we started using All Things Social.",
        name: "James Mwangi",
        title: "Brand",
        stars: "/images/4stars.png",
        image: "/images/testimonialuser1.jpeg",
      },
      {
        content:
          "As an influencer with a busy schedule, staying organized and maximizing my partnerships is crucial. All Things Social has become my go-to platform for managing collaborations. The detailed analytics and communication tools have helped me deliver better results for brands, while the simplicity of the platform makes it a joy to use.",
        name: "Lola Owino",
        title: "Influencer",
        stars: "/images/4stars.png",
        image: "/images/testimonialuser3.jpeg",
      },
      {
        content:
          "In the ever-evolving landscape of influencer marketing, finding a reliable platform is like striking gold. All Things Social not only simplifies the influencer discovery process but also provides in-depth insights that have been crucial in refining our approach. Their system has saved us time and effort while enhancing our brand's impact in the digital space.",
        name: "Evans Kamau",
        title: "Brand",
        stars: "/images/4stars.png",
        image: "/images/testimonialuser4.jpeg",
      },
    ];

    let i = 0;
    let testimonialsContainer = document.getElementById("testimonials");

    function displayTestimonial() {
      testimonialsContainer.innerHTML = `
        
          <div class="md:w-[659px] w-[270px] flex flex-col gap-4  justify-center text-center items-center p-8 md:h-[521px] bg-white transition-all ease-in-out duration-500">
          <img
              src="${testimonials[i].image}"
            alt="testimonial image"
            class="rounded-full border-2 border-purple-500  md:w-[80px] md:h-[80px] w-[40px] h-[40px] object-cover"
          />
        
          <div>
            <p class="text-xl font-semibold text-purple-500 poppins-semibold">
              ${testimonials[i].name}
            </p>
            <p class="inter-extra-bold ">
              ${testimonials[i].title}
            </p>
          </div>
  
          <p class="inter-regular text-xs md:text-base">
          ${testimonials[i].content}
           
          </p>
        </div>
  
      `;
    }

    displayTestimonial();

    // Function to cycle through testimonials
    // function cycleTestimonials() {
    //   i = (i + 1) % testimonials.length; // Increment i and wrap around if it exceeds the testimonials length
    //   displayTestimonial();
    // }

    // Call cycleTestimonials every 3 seconds (adjust as needed)
    // setInterval(cycleTestimonials, 4000);

    // Function to display previous testimonial
    function prevTestimonial() {
      i = i - 1;
      if (i < 0) {
        i = testimonials.length - 1;
      }
      displayTestimonial();
    }

    // Function to display next testimonial
    function nextTestimonial() {
      i = i + 1;
      if (i >= testimonials.length) {
        i = 0;
      }

      displayTestimonial();
    }

    document.getElementById("next").addEventListener("click", nextTestimonial);
    document.getElementById("prev").addEventListener("click", prevTestimonial);
  },
};

Hooks.Chart = {
  mounted() {
    var events_in_the_system = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
    ];
    var total_tickets_for_each_event = [
      100, 200, 350, 240, 500, 300, 700, 1000,
    ];
    var total_tickets_scanned_for_each_event = [
      200, 300, 450, 800, 900, 500, 800, 600,
    ];

    var barColors = [
      "white",
      "white",
      "white",
      "white",
      "white",
      "white",
      "white",
      "white",
    ];

    new Chart("myChart", {
      type: "bar",
      color: "white",
      data: {
        labels: events_in_the_system,
        datasets: [
          {
            label: "Total Post Engagements",
            backgroundColor: barColors,
            data: total_tickets_for_each_event,
          },
          {
            label: "Total Reel Engagements",
            backgroundColor: barColors,
            data: total_tickets_scanned_for_each_event,
          },
        ],
      },
      options: {
        responsive: true,

        scales: {
          y: {
            ticks: { color: "white", beginAtZero: true },
          },
          x: {
            ticks: { color: "white", beginAtZero: true },
          },
        },
        plugins: {
          title: {
            display: true,
            text: "Total Engagements for Posts and Reels",
            color: "white",
          },
          legend: {
            labels: {
              color: "white",
            },
          },
        },
      },
    });
  },
};

Hooks.Chart2 = {
  mounted() {
    var xValues = ["Kenya", "Uganda", "Nigeria", "Qatar", "Tanzania"];
    var yValues = [1200, 1000, 980, 758, 800];
    var barColors = ["#b91d47", "#00aba9", "#2b5797", "#e8c3b9", "#1e7145"];

    new Chart("myChart2", {
      type: "line",
      color: "white",

      data: {
        labels: xValues,
        datasets: [
          {
            backgroundColor: "white",
            label: "Followers per Country",

            data: yValues,
            borderColor: "white",
          },
        ],
      },
      scales: {
        y: {
          ticks: { color: "white", beginAtZero: true },
        },
        x: {
          ticks: { color: "white", beginAtZero: true },
        },
      },

      options: {
        responsive: true,

        scales: {
          y: {
            ticks: { color: "white", beginAtZero: true },
          },
          x: {
            ticks: { color: "white", beginAtZero: true },
          },
        },
        plugins: {
          title: {
            display: true,
            text: "Followers per Country",
            color: "white",
          },
          legend: {
            labels: {
              color: "white",
            },
          },
        },
      },
    });
  },
};

Hooks.ClearFlash = {
  mounted() {
    function timeMsg() {
      window.setTimeout("clearMsg()", 5000); //10secs
    }

    //

    function clearMsg() {
      document.getElementById("hideMsg").innerText = "";
    }

    timeMsg();
  },
};
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});
// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
