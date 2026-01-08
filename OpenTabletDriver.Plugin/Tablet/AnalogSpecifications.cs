using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace OpenTabletDriver.Plugin.Tablet
{
    /// <summary>
    /// Device specifications for an analog reporting device, such as knobs, wheels &amp; strips (more commonly touch strips).
    /// </summary>
    public class AnalogSpecifications
    {
        /// <summary>
        /// The amount of steps in the analog device, minus 1 (as step 0 is a valid step)
        /// <para/>
        /// For both relative and absolute wheels, this is the amount of steps per 360 degrees
        /// </summary>
        [Required(ErrorMessage = $"{nameof(StepCount)} must be defined")]
        [JsonProperty(Order = int.MinValue)]
        public uint StepCount { set; get; }

        /// <summary>
        /// Does the device report relative position (deltas) or absolute position (exact value)
        /// </summary>
        [Required(ErrorMessage = $"{nameof(IsRelative)} must be defined")]
        [JsonProperty(Order = int.MinValue)]
        public bool IsRelative { get; set; }
    }
}
