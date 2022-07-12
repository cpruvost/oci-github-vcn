terraform {
	backend "remote" {
		organization = "oracledemo" # org name from step 2.
		workspaces {
			name = "my-demo" # name for your app's state.
		}
	}
}