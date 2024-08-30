import { StarResponse } from '../../model/StarResponse'

@Component
export struct StarItem{
  @Prop item: StarResponse;
  build() {
    Column(){
      Text(this.item.name)
      Text(this.item.description)
    }
  }
}